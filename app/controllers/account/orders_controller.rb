module Account
  class OrdersController < ApplicationController
    before_action :require_login

    def index
      @orders = current_user.orders.where.not(stripe_checkout_session_id: nil).where.not(status: "pending").order(created_at: :desc)
    end
  end
end
