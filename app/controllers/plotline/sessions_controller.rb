require_dependency "plotline/application_controller"

module Plotline
  class SessionsController < ApplicationController
    skip_before_action :authenticate_user

    layout 'plotline/plain'

    def new
    end

    def create
      user = User.find_by_email(params[:email])
      if user && user.authenticate(params[:password])
        cookies.permanent[:auth_token] = user.auth_token

        flash[:notice] = "Hello!"
        redirect_to root_url
      else
        flash.now.alert = "Invalid email and/or password"
        render "new"
      end
    end

    def destroy
      cookies.delete(:auth_token)
      redirect_to root_url
    end
  end
end
