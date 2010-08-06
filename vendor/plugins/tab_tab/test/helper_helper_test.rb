require File.dirname(__FILE__) + '/test_helper'

class HelperHelperTest < Test::Unit::TestCase

  def test_tab_name_helper
    view            = YeOldeView.new
    view.controller = controller = StuffController.new

    assert_equal 'Home',     view.tab_name_helper(:home)
    assert_equal 'Settings', view.tab_name_helper(:account => :settings)
    assert_equal 'User Preferences', view.tab_name_helper(:user_preferences)
  end

  def test_tab_html_attributes_helper
    view            = YeOldeView.new
    view.controller = controller = StuffController.new

    assert_equal( { :id => 'stuff_tab', :class => 'active' },
      view.tab_html_attributes_helper(:stuff) )

    assert_equal( { :id => 'not_stuff_tab' },
      view.tab_html_attributes_helper(:not_stuff) )

    assert_equal( { :id => 'x_tab', :class => 'x' },
      view.tab_html_attributes_helper(:x, :class => 'x') )

    assert_equal( { :id => 'stuff_tab', :class => 'active x' },
      view.tab_html_attributes_helper(:stuff, :class => 'x') )

    assert_equal( { :id => 'y', :class => 'active x' },
      view.tab_html_attributes_helper(:stuff, :class => 'x', :id => 'y') )
  end

  def test_tab_activaton_status_helper
    view            = YeOldeView.new
    view.controller = controller = StuffController.new

    assert  view.tab_activaton_status_helper(:stuff)
    assert !view.tab_activaton_status_helper(:not_stuff)
  end
end
