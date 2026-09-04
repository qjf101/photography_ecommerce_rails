module Admin
  class OrdersController < Admin::BaseController
    before_action :set_order, only: [:show, :complete, :refund]

    def index
      @orders = Order.where.not(stripe_checkout_session_id: nil).where.not(status: "pending").order(created_at: :desc)
    end

    def show
    end

    def complete
      @order.update!(status: "completed")
      redirect_to admin_order_path(@order), notice: "Order marked completed."
    end

    def refund
      if @order.refunded?
        redirect_to admin_order_path(@order), alert: "Order is already refunded." and return
      end

      Stripe::Refund.create(payment_intent: @order.stripe_payment_intent_id)
      @order.update!(status: "refunded")
      redirect_to admin_order_path(@order), notice: "Order refunded."
    rescue Stripe::StripeError => e
      redirect_to admin_order_path(@order), alert: "Refund failed: #{e.message}"
    end

    private

    def set_order
      @order = Order.find_by!(confirmation_token: params[:id])
    end
  end
end
