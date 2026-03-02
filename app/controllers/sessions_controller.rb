class SessionsController < ApplicationController
  before_action :require_no_authentication, only: [ :new, :create ]

  def new
  end

  def create
    user = User.find_by(username: params[:username])

    if user&.activated? && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: "登录成功"
    else
      flash.now[:alert] = user&.activated? == false ? "账号尚未激活，请通过激活链接设置密码" : "用户名或密码错误"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to new_session_path, notice: "已退出登录"
  end
end
