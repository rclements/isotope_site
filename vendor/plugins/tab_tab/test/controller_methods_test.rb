require File.dirname(__FILE__) + '/test_helper'

class ControllerMethodsTest < Test::Unit::TestCase

  def test_controller_level_tab
    assert_equal Tab.new(:stuff), StuffController.new.current_tab
  end

  def test_default_controller_level_tab
    assert_equal Tab.new(:bars), BarsController.new.current_tab
  end

  def test_action_level_tab
    assert_equal Tab.new(:stuff => :edit),
                 StuffController.new.edit.current_tab
  end

  def test_default_action_level_tab
    assert_equal Tab.new(:stuff), StuffController.new.show.current_tab
  end

  def test_default_controller_and_action_level_tab
    assert_equal Tab.new(:bars), BarsController.new.show.current_tab
  end
end
