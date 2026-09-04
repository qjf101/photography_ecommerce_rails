require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  test "redirects guests away from the user list" do
    get admin_users_url
    assert_redirected_to root_path
  end

  test "redirects logged-in non-admins away too" do
    sign_in(users(:one), "password1")
    get admin_users_url
    assert_redirected_to root_path
  end

  test "allows an admin to view the user list" do
    sign_in_as_admin
    get admin_users_url
    assert_response :success
  end

  test "allows an admin to view a single user" do
    sign_in_as_admin
    get admin_user_url(users(:one))
    assert_response :success
  end

  test "allows an admin to delete another user" do
    sign_in_as_admin

    assert_difference("User.count", -1) do
      delete admin_user_url(users(:one))
    end

    assert_redirected_to admin_users_url
  end

  test "does not allow an admin to delete their own account from the admin panel" do
    sign_in_as_admin

    assert_no_difference("User.count") do
      delete admin_user_url(users(:admin))
    end

    assert_redirected_to admin_users_url
  end

  private

  def sign_in_as_admin
    sign_in(users(:admin), "adminpass1")
  end

  def sign_in(user, password)
    post login_url, params: { session: { email: user.email, password: password } }
  end
end
