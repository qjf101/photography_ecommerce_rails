class OrderMailer < ApplicationMailer
  def confirmation(order)
    @order = order

    mail to: @order.email, subject: "Order confirmation ##{@order.confirmation_token}"
  end
end
