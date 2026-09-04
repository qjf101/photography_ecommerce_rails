require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get sign_up_url
    assert_response :success
  end

  test "should create user and log them in" do
    assert_difference("User.count") do
      post users_url, params: { user: { email: "newuser@test.com", first_name: "New", last_name: "User", password: "password123", password_confirmation: "password123" } }
    end

    assert_redirected_to account_url
    assert_equal User.last.id, session[:user_id]
  end

  test "silently rejects signup when the honeypot field is filled in" do
    assert_no_difference("User.count") do
      post users_url, params: { website: "http://spam.example.com", user: { email: "bot@test.com", first_name: "Bot", last_name: "Spam", password: "password123", password_confirmation: "password123" } }
    end

    assert_redirected_to root_path
  end

  test "does not create a user with invalid params" do
    assert_no_difference("User.count") do
      post users_url, params: { user: { email: "not-an-email", first_name: "New", last_name: "User", password: "password123", password_confirmation: "password123" } }
    end

    assert_response :unprocessable_content
  end
end
