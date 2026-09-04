module Admin
  class UsersController < Admin::BaseController
    before_action :set_user, only: [:show, :destroy]

    def index
      @users = User.order(:email)
    end

    def show
    end

    def destroy
      if @user == current_user
        redirect_to admin_users_path, alert: "You can't delete your own account from here." and return
      end

      @user.destroy!
      redirect_to admin_users_path, notice: "User deleted.", status: :see_other
    end

    private

    def set_user
      @user = User.find(params[:id])
    end
  end
end
