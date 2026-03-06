class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.order(created_at: :desc)
    @users = @users.where("username ILIKE ? OR email ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
  end

  def show
    @books  = @user.books.order(created_at: :desc)
    @finds  = @user.finds.includes(:book).order(found_at: :desc)
    @badges = @user.badges
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: "User updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: "User deleted."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :email, :role, :points, :bio)
  end
end