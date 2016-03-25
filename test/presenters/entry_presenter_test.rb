require 'test_helper'

module Plotline
  class EntryPresenterTest < ActionView::TestCase
    test "custom markdown parsing" do
      @entry = plotline_entries(:sample)
      @entry.body = File.read(File.join('test', 'fixtures', 'markdown', 'document.md'))
      expected_output = File.read(File.join('test', 'fixtures', 'markdown', 'expected_output.html'))

      presenter = Plotline::EntryPresenter.new(@entry, view)

      assert_equal expected_output, presenter.body_markdown
    end
  end
end