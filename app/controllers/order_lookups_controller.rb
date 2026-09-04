class OrderLookupsController < ApplicationController
  rate_limit to: 5, within: 3.minutes, only: :create,
    with: -> { redirect_to order_lookup_path, alert: "Too many attempts. Please try again later." }

  def new
  end

  def create
    order = Order.find_by(confirmation_token: params[:confirmation_token], email: params[:email])

    if order
      session[:authorized_order_tokens] ||= []
      session[:authorized_order_tokens] << order.confirmation_token
      redirect_to order_path(order)
    else
      flash.now[:alert] = "Couldn't get order"
      render :new, status: :unprocessable_entity
    end
  end
end
