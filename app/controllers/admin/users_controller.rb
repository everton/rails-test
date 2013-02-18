class Admin::UsersController < ApplicationController
  respond_to :html

  require_admin

  def index
    @users = User.all
    respond_with :admin, @users
  end

  def new
    @user = User.new
    respond_with :admin, @user
  end

  def create
    is_admin = params[:user].delete(:is_admin)

    params[:user][:password_confirmation] ||= params[:user][:password]

    @user = User.new params[:user]
    @user.is_admin = is_admin
    @user.save

    respond_with :admin, @user, location: admin_users_path
  end

  def edit
    @user = User.find params[:id]
    respond_with :admin, @user
  end

  def update
    @user = User.find params[:id]

    is_admin = params[:user].delete(:is_admin)

    @user.update_attributes params[:user]
    @user.is_admin = is_admin
    @user.save

    respond_with :admin, @user, location: admin_users_path
  end

  def destroy
    @user = User.find params[:id]
    @user.destroy

    respond_with :admin, @user, location: admin_users_path
  end
end
