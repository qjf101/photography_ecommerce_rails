class OrdersController < ApplicationController
  before_action :set_order
  before_action :authorize_order_access

  def show
  end

  def request_refund
    if @order.paid? || @order.completed?
      @order.update!(status: "refund_pending")
      redirect_to order_path(@order), notice: "Refund requested. We'll review it shortly."
    else
      redirect_to order_path(@order), alert: "This order can't be refunded."
    end
  end

  private

  def set_order
    # treats "no such order" and "not authorized" identically, so a bad
    # token doesn't reveal whether it belongs to a real order.
    @order = Order.find_by(confirmation_token: params[:id])
  end

  def authorize_order_access
    return if @order && current_user && @order.user_id == current_user.id
    return if @order && session[:authorized_order_tokens]&.include?(params[:id])

    redirect_to order_lookup_path
  end
end
