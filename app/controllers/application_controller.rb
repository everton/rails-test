class ApplicationController < ActionController::Base
  protect_from_forgery

  private
  def self.require_login(options = {})
    before_filter(options) do
      redirect_to new_session_path unless logged_in?
      return false
    end
  end

  def logged_in?
    current_user.present?
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  helper_method :current_user, :logged_in?
end
