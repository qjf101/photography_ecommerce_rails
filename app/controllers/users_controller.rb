class UsersController < ApplicationController
  rate_limit to: 5, within: 10.minutes, only: :create,
    with: -> { redirect_to sign_up_path, alert: "Too many signup attempts. Please try again later." }

  def new
    @user = User.new
  end

  def create
    # Honeypot field for bots - redirect as if nothing happened
    return redirect_to root_path if params[:website].present?

    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      redirect_to account_path, notice: "Welcome! Your account was created."
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.expect(user: [ :email, :first_name, :last_name, :password, :password_confirmation ])
  end
end
