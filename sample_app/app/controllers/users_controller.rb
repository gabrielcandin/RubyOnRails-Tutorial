class UsersController < ApplicationController
  # Define what are allowed for which user

  # Refactored code above into:
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]

  def index
  @users = User.paginate( page: params[:page] )
  end

  def show
  @user = User.find(params[:id])
  @microposts = @user.microposts.paginate(page: params[:page])
  end 

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = 'Please check your email to activate your account!'
      redirect_to(root_url)

    else
      render 'new'
    end
  end

  def edit
    @user = User.find( params[:id] )
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params) # returns true only on succesful update!
      # Handle a successful update.
      flash[:success] = "Profile has been successfully updated!"
      redirect_to (@user)
    else
      render 'edit'
    end
  end

  def destroy
    User.find( params[:id] ).destroy
    flash[:success] = 'User successfully deleted!'
    redirect_to (users_url)
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end

  # Before filters

  # Confirms the correct user.
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  # Confirms an admin user.
  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end