class SessionsController < ApplicationController
  rate_limit to: 5, within: 3.minutes, only: :create,
    with: -> { redirect_to login_path, alert: "Too many login attempts. Please try again later." }

  # TODO: add two-factor authentication for admin accounts (e.g. TOTP via
  # the rotp gem) - rate limiting here only slows down brute-forcing,
  # it doesn't stop a leaked/guessed password from working.

  def new
  end

  def create
    email, password = params[:session].values_at(:email, :password)
    user = User.find_by(email: email)&.authenticate(password)

    if user
      session[:user_id] = user.id
      redirect_to root_path
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to root_path
  end
end
