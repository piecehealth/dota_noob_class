class ActivationsController < ApplicationController
  before_action :find_user_by_token

  def show
    redirect_to new_session_path, notice: "账号已激活，请直接登录" if @user.activated?
  end

  def update
    if @user.activated?
      redirect_to new_session_path, notice: "账号已激活，请直接登录"
      return
    end

    if @user.activate!(**activation_params.to_h.symbolize_keys)
      session[:user_id] = @user.id
      redirect_to root_path, notice: "激活成功，欢迎加入！"
    end
  rescue ActiveRecord::RecordInvalid
    flash.now[:alert] = @user.errors.full_messages.to_sentence
    render :show, status: :unprocessable_entity
  end

  private

  def activation_params
    params.require(:user).permit(:username, :password, :password_confirmation)
  end

  def find_user_by_token
    @user = User.find_by(activation_token: params[:token])
    redirect_to new_session_path, alert: "无效的激活链接" unless @user
  end
end
