class OrderCheckoutsController < ApplicationController
  SHIPPING_RATE_CENTS = 500

  rate_limit to: 10, within: 5.minutes, only: :create,
    with: -> { redirect_to cart_path, alert: "Too many checkout attempts. Please try again later." }

  def create
    redirect_to cart_path and return unless current_cart&.cart_items&.any?

    if current_user.nil? && User.exists?(email: params[:email])
      redirect_to login_path, alert: "An account already exists with this email. Please log in to continue." and return
    end

    Order.transaction do
      @order = Order.create!(user: current_user, cart: current_cart, email: current_user&.email || params[:email], total_cents: current_cart.total_cents)
      current_cart.cart_items.each do |cart_item|
        LineItem.create!(quantity: cart_item.quantity, unit_price_cents: cart_item.product.price_cents, order_id: @order.id, product_id: cart_item.product_id)
      end
    end

    begin
      checkout_session = Stripe::Checkout::Session.create(
        mode: "payment",
        customer_email: @order.email,
        shipping_address_collection: { allowed_countries: ["US"] },
        shipping_options: [
          {
            shipping_rate_data: {
              type: "fixed_amount",
              fixed_amount: { amount: SHIPPING_RATE_CENTS, currency: "usd" },
              display_name: "Standard Shipping"
            }
          }
        ],
        line_items: @order.line_items.map do |line_item|
          {
            price_data: {
              currency: "usd",
              unit_amount: line_item.unit_price_cents,
              product_data: { name: line_item.product.name }
            },
            quantity: line_item.quantity
          }
        end,
        success_url: order_url(@order),
        cancel_url: cart_url
      )
    rescue Stripe::StripeError => e
      @order.destroy!
      redirect_to cart_path, alert: "We couldn't start checkout: #{e.message}. Please try again." and return
    end

    @order.update!(stripe_checkout_session_id: checkout_session.id)

    session[:authorized_order_tokens] ||= []
    session[:authorized_order_tokens] << @order.confirmation_token

    redirect_to checkout_session.url, allow_other_host: true
  end
end
