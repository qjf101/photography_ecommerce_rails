require "test_helper"

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
class UserTest < ActiveSupport::TestCase
  test "authenticates with the correct password" do
    assert users(:one).authenticate("password1")
  end

  test "does not authenticate with the wrong password" do
    assert_not users(:one).authenticate("wrong_password")
  end

  test "requires an email" do
    user = User.new(first_name: "Test", last_name: "User", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "requires a unique email, case-insensitively" do
    user = User.new(email: "TEST@TEST.COM", first_name: "Test", last_name: "User",
                     password: "password123", password_confirmation: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "requires a valid email format" do
    user = User.new(email: "not-an-email", first_name: "Test", last_name: "User", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "must be a valid email address"
  end

  test "normalizes email to a stripped, downcased value" do
    user = User.create!(email: "  Mixed@Case.com  ", first_name: "Test", last_name: "User",
                         password: "password123", password_confirmation: "password123")
    assert_equal "mixed@case.com", user.email
  end

  test "requires a first and last name" do
    user = User.new(email: "new@test.com", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:first_name], "can't be blank"
    assert_includes user.errors[:last_name], "can't be blank"
  end

  test "requires a password on create" do
    user = User.new(email: "new@test.com", first_name: "Test", last_name: "User")
    assert_not user.valid?
    assert_includes user.errors[:password], "can't be blank"
  end
end
