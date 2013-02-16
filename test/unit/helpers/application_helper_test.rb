require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  setup do
    # @view_flow is a Hash used by #content_for
    # and not created on tests by default
    @view_flow = FakeFlow.new
  end

  test 'action title returns raw header tag' do
    expected = content_tag(:h1, 'Foo')
    assert_equal expected, action_title('Foo')
  end

  test 'action title can accept block to be captured' do
    expected = "<h1>Foo <span>Bar</span></h1>"
    returned = action_title do %q{
      Foo
      <span>Bar</span>
    } end

    assert_equal expected, returned
  end

  test 'action title sets content_for :page_title' do
    action_title 'Bar'
    assert_equal 'Bar', content_for(:title)
  end

  test 'action title should strip tags with captured blocks' do
    action_title { "Foo\n\n\r    \t<span>Bar     </span>\n\r\n\t" }
    assert_equal 'Foo Bar', content_for(:title)
  end

  test 'action title forward option parameters for header' do
    expected = content_tag(:h1, 'Foo', bar: :zaloom)
    assert_equal expected, action_title('Foo', bar: :zaloom)
  end

  private
  class FakeFlow < Hash
    alias_method :append, '[]='
    alias_method :get,    '[]'
  end
end
