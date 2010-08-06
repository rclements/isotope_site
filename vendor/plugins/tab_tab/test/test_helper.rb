require 'rubygems'
require 'tab_tab'

begin
  require 'leftright'
rescue LoadError
  puts "Install 'leftright' to get awesome output during tests"
end unless ENV['TM_BUNDLE_PATH']

class Test::Unit::TestCase
  include TabTab

  require File.join(File.dirname(__FILE__), 'fixtures', 'ye_olde_view')
  require File.join(File.dirname(__FILE__), 'fixtures', 'bars_controller')
  require File.join(File.dirname(__FILE__), 'fixtures', 'stuff_controller')

  def assert_activation(tab_literal, *other_tab_literal)

    tab, other_tab = Tab.new(tab_literal), Tab.new(other_tab_literal)

    assert_block "#{tab.inspect} does not activate #{other_tab.inspect}" do
      tab.activates? other_tab
    end
  end

  def assert_no_activation(tab_literal, *other_tab_literal)

    tab, other_tab = Tab.new(tab_literal), Tab.new(other_tab_literal)

    assert_block "#{tab.inspect} activates #{other_tab.inspect}" do
      not tab.activates? other_tab
    end
  end
end