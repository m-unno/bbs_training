class LoginsController < ApplicationController

  def create
    user = User.find_by_account params[:account]
    if user && user.authenticate(params[:pass])
      session[:user_id] = user.id
#      render 'login_success'
      redirect_to "/"
    else
      # パラメータを破棄する
      params = nil
      render 'login_failure'
    end
  end
  
  def destroy
    session[:user_id] = nil
    redirect_to "/"
  end
end
