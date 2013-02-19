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

      # TODO: put current_order logic at some helper
      if session[:order_id]
        @order = Order.find session[:order_id]
        @order.user = @user
        @order.save
      end

      redirect_to root_url
    else
      flash[:error] = 'Invalid password or username'
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url
  end
end
