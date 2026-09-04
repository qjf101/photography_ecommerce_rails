require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  test "redirects guests to login" do
    get account_url
    assert_redirected_to login_path
  end

  test "shows the logged-in user's own account" do
    sign_in(users(:one), "password1")
    get account_url
    assert_response :success
    assert_match users(:one).email, response.body
  end

  test "allows the logged-in user to edit their own account" do
    sign_in(users(:one), "password1")
    get edit_account_url
    assert_response :success
  end

  test "allows the logged-in user to update their own account" do
    sign_in(users(:one), "password1")
    patch account_url, params: { user: { first_name: "Updated" } }
    assert_redirected_to account_url
    assert_equal "Updated", users(:one).reload.first_name
  end

  test "leaving password blank on update keeps the current password" do
    sign_in(users(:one), "password1")
    patch account_url, params: { user: { first_name: "Updated", password: "", password_confirmation: "" } }
    assert users(:one).reload.authenticate("password1")
  end

  test "allows the logged-in user to delete their own account" do
    sign_in(users(:one), "password1")

    assert_difference("User.count", -1) do
      delete account_url
    end

    assert_redirected_to root_url
    assert_nil session[:user_id]
  end

  private

  def sign_in(user, password)
    post login_url, params: { session: { email: user.email, password: password } }
  end
end
