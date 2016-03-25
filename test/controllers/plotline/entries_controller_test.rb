require 'test_helper'

module Plotline
  class EntriesControllerTest < ActionController::TestCase
    setup do
      @entry = plotline_entries(:sample)
      @routes = Engine.routes

      EntriesController.any_instance.stubs(:current_user).returns(Plotline::User.new)
    end

    test "should redirect to sign_in_url if not logged in" do
      EntriesController.any_instance.stubs(:current_user).returns(nil)

      get :index, params: { content_class: 'BlogPost' }
      assert_redirected_to '/plotline/sign-in'
    end

    test "should get index" do
      get :index, params: { content_class: 'BlogPost' }
      assert_response :success
      assert_not_nil assigns(:entries)
    end

    test "should show entry" do
      get :show, params: { id: @entry, content_class: 'BlogPost' }
      assert_response :success
    end

    test "should destroy entry" do
      assert_difference('Entry.count', -1) do
        delete :destroy, params: { content_class: 'BlogPost', id: @entry }
      end

      assert_redirected_to entries_path(content_class: 'blog_posts')
    end
  end
end
