require File.dirname(__FILE__) + '/test_helper'

class TabTest < Test::Unit::TestCase

  def test_tab_name_generation_from_literal
    assert_equal 'Home',             Tab.new(:home                ).name
    assert_equal 'Settings',         Tab.new(:account => :settings).name
    assert_equal 'User Preferences', Tab.new(:user_preferences    ).name
  end

  def test_html_id_generation_from_literal
    assert_equal 'home_tab',             Tab.new(:home).html_id
    assert_equal 'user_preferences_tab', Tab.new(:user_preferences).html_id
    assert_equal 'account_settings_tab',
      Tab.new(:account => :settings).html_id
  end

  def test_equivalence_of_different_tab_literal_forms
    assert_equal Tab.new(:pictures => :shared),
                 Tab.new('pictures',  'shared')

    assert_equal Tab.new('pictures' => { :shared => 'organize' }),
                 Tab.new(:pictures,      'shared',  :organize)

    assert_not_equal Tab.new(:pictures => { :shared => :organize }),
                     Tab.new('pictures',   'organize',  'shared')
  end

  def test_proper_activation_of_ancestor_tabs
    assert_activation [ :pets, :dogs, :big ], :pets
    assert_activation [ :pets, :dogs, :big ], :pets => :dogs
    assert_activation [ :pets, :dogs, :big ],
                      [ :pets, :dogs, :big ]

    assert_no_activation :dogs, :pets => :dogs
    assert_no_activation :pets, :pets => :dogs

    assert_no_activation [ :planets, :countries, :cities    ],
                         [ :planets, :cities,    :countries ]
  end
end
