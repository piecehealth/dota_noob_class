class SessionsController < ApplicationController
  def new
    redirect_to root_path if authenticated?
  end

  def create
    user = User.find_by(username: params[:username])

    if user&.authenticate(params[:password]) && user.admin?
      session[:user_id] = user.id
      redirect_to root_path, notice: "欢迎回来，#{user.display_name}"
    else
      redirect_to new_session_path, alert: "用户名或密码错误，或无管理员权限"
    end
  end

  def destroy
    reset_session
    redirect_to new_session_path, notice: "已退出登录"
  end
end
