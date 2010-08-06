require File.dirname(__FILE__) + '/test_helper'

class ViewTest < Test::Unit::TestCase

  def test_tab_scope_helper
    view            = YeOldeView.new
    view.controller = controller = StuffController.new

    simple = view.content_tag(:li, :id => 'admin_users_tab') do
      view.link_to('Users', '/admin/users/')
    end

    complex = view.content_tag(:li, :id => 'a_b_c_d_tab') do
      view.link_to('D', '/a/b/c/d/')
    end

    view.tabs_for :admin do |admin|
      assert_equal simple, admin.tab('/admin/users/', :users)
    end

    view.tabs_for :a => :b do |ab|
      assert_equal complex, ab.tab('/a/b/c/d/', ['c', 'd'])
    end
  end

  def test_of_builtin_tab_helper
    v            = YeOldeView.new
    v.controller = controller = StuffController.new

    minimal = v.content_tag(:li, :id => 'top_tab') do
      v.link_to('Top', '/')
    end

    nested = v.content_tag(:li, :id => 'top_under_lower_tab') do
      v.link_to('Lower', '/')
    end

    with_name = v.content_tag(:li, :id => 'top_tab') do
      v.link_to('Back Home', '/')
    end

    with_id = v.content_tag(:li, :id => 'top_tab', :id => 't7') do
      v.link_to('Top', '/')
    end

    with_class = v.content_tag(:li, :id => 'top_tab', :class => 'nav') do
      v.link_to('Top', '/')
    end

    active = v.content_tag(:li, :id => 'stuff_tab', :class => 'active') do
      v.link_to('Stuff', '/')
    end

    active_nav = v.content_tag(:li, :id => 'stuff_tab',
      :class => 'active nav') do

      v.link_to('Stuff', '/')
    end

    assert_equal minimal,    v.tab('/', :top)
    assert_equal nested,     v.tab('/', :top => { :under => :lower })
    assert_equal with_name,  v.tab('/', :top, :name => 'Back Home')
    assert_equal with_id,    v.tab('/', :top, :html => { :id    => 't7'  })
    assert_equal with_class, v.tab('/', :top, :html => { :class => 'nav' })
    assert_equal active,     v.tab('/', :stuff)
    assert_equal active_nav, v.tab('/', :stuff, :html => { :class => 'nav' })

    assert_raises ArgumentError do
      v.tab '/', :top, :invalid_key => 'Kaboom'
    end
  end
end