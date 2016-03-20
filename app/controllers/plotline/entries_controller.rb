require_dependency "plotline/application_controller"

module Plotline
  class EntriesController < ApplicationController
    before_action :set_entry, only: [:show, :edit, :update, :destroy, :preview]

    def index
      @entries = Entry.where(type: content_class)
    end

    def show
    end

    def destroy
      @entry.destroy
      redirect_to content_entries_path, notice: 'Entry was successfully destroyed.'
    end

    private

    def set_entry
      @entry = Entry.find(params[:id])
    end

    def content_class
      @content_class ||= params[:content_class].classify
    end
    helper_method :content_class
  end
end
