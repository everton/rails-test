class UsersController < ApplicationController
  respond_to :html

  def new
    @user = User.new
    respond_with @user
  end

  def create
    @user = User.create params[:user]

    session[:user_id] = @user if @user.errors.empty?

    respond_with @user, location: '/'
  end

  def edit
    @user = User.find params[:id]
    respond_with @user
  end

  def update
    @user = User.find params[:id]
    @user.update_attributes params[:user]

    respond_with @user, location: '/'
  end

  def destroy
    @user = User.find params[:id]
    @user.destroy

    session[:user_id] = nil

    respond_with @user, location: '/'
  end
end
