# == Schema Information
#
# Table name: orders
#
#  id                         :integer          not null, primary key
#  confirmation_token         :string
#  email                      :string           not null
#  shipping_address_line1     :string
#  shipping_address_line2     :string
#  shipping_city              :string
#  shipping_country           :string
#  shipping_name              :string
#  shipping_postal_code       :string
#  shipping_state             :string
#  status                     :string           default("pending"), not null
#  total_cents                :integer          default(0), not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  cart_id                    :integer
#  stripe_checkout_session_id :string
#  stripe_payment_intent_id   :string
#  user_id                    :integer
#
# Indexes
#
#  index_orders_on_cart_id                     (cart_id)
#  index_orders_on_confirmation_token          (confirmation_token) UNIQUE
#  index_orders_on_stripe_checkout_session_id  (stripe_checkout_session_id) UNIQUE
#  index_orders_on_user_id                     (user_id)
#
# Foreign Keys
#
#  cart_id  (cart_id => carts.id) ON DELETE => nullify
#  user_id  (user_id => users.id) ON DELETE => nullify
#
class Order < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :cart, optional: true
  has_many :line_items, dependent: :destroy

  has_secure_token :confirmation_token

  validates :email, presence: true,
    length: { maximum: 255 },
    format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }

  normalizes :email, with: ->(email) { email.strip.downcase }

  enum :status, {
    pending: "pending",
    paid: "paid",
    completed: "completed",
    refund_pending: "refund_pending",
    refunded: "refunded",
    failed: "failed"
  }

  def to_param
    confirmation_token
  end
end
