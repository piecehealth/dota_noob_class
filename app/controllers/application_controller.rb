class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_current_user

  private

  def set_current_user
    @current_user = User.find_by(id: session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def current_user
    @current_user
  end

  def require_authentication
    redirect_to new_session_path, alert: "请先登录" unless @current_user
  end

  def require_no_authentication
    redirect_to root_path if @current_user
  end
end
