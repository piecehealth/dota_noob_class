class PasswordsController < ApplicationController
  before_action :require_authentication

  def edit
  end

  def update
    unless current_user.authenticate(params[:current_password])
      flash.now[:alert] = "当前密码错误"
      return render :edit, status: :unprocessable_entity
    end

    if current_user.update(password: params[:password], password_confirmation: params[:password_confirmation])
      redirect_to edit_password_path, notice: "密码修改成功"
    else
      flash.now[:alert] = current_user.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end
end
