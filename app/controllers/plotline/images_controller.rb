require_dependency "plotline/application_controller"

module Plotline
  class ImagesController < ApplicationController
    def index
      @images = Image.order('id desc')
    end

    def show
      @image = Image.find(params[:id])
    end

    def destroy
      @image = Image.find(params[:id])
      @image.destroy
      redirect_to :back, notice: 'Image was successfully destroyed.'
    end
  end
end
