# TODO: rename to accounts controller
class UsersController < ApplicationController
  respond_to :html

  require_login except: [:new, :create]

  def new
    redirect_to '/' and return if logged_in?

    @user = User.new
    respond_with @user
  end

  def create
    redirect_to '/' and return if logged_in?

    @user = User.create params[:user]

    session[:user_id] = @user if @user.errors.empty?

    respond_with @user, location: '/'
  end

  def edit
    @user = current_user
    respond_with @user
  end

  def update
    @user = current_user
    @user.update_attributes params[:user]

    respond_with @user, location: '/'
  end

  def destroy
    @user = current_user
    @user.destroy

    session[:user_id] = nil

    respond_with @user, location: '/'
  end
end
