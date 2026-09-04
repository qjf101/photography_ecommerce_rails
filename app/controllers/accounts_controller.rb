class AccountsController < ApplicationController
  before_action :require_login

  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(user_params)
      redirect_to account_path, notice: "Account updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    current_user.destroy!
    reset_session
    redirect_to root_path, notice: "Your account has been deleted."
  end

  private

  def user_params
    params.expect(user: [ :email, :first_name, :last_name, :password, :password_confirmation ])
  end
end
