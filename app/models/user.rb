# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  admin              :boolean          default(FALSE), not null
#  email              :string           not null
#  first_name         :string           not null
#  last_name          :string           not null
#  password_digest    :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  stripe_customer_id :string
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
class User < ApplicationRecord
    has_secure_password

    has_many :orders

    validates :email, presence: true,
        uniqueness: { case_sensitive: false },
        length: { maximum: 255 },
        format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
    validates :first_name, presence: true
    validates :last_name, presence: true

    normalizes :email, with: ->(email) { email.strip.downcase }
end
