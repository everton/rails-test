# -*- coding: utf-8 -*-

class SessionsController < ApplicationController
  respond_to :html

  def new
    @user = User.new
    respond_with @user
  end

  def create
    @user = User.where(email: params[:email]).first

    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect_to root_url
    else
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url
  end
end
