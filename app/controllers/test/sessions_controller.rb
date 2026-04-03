class Test::SessionsController < ApplicationController
  def sign_in
    if Rails.env.test?
      user = User.find(params[:user_id])
      session[:user_id] = user.id
      head :ok
    else
      head :not_found
    end
  end
end
