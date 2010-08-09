require 'action_controller'
require 'action_view'

require 'tab_tab/controller_instance_methods'
require 'tab_tab/controller_methods'
require 'tab_tab/scope'
require 'tab_tab/tab'
require 'tab_tab/view_helpers'

class ActionController::Base
  protected

  class << self
    include ::TabTab::ControllerMethods
  end

  include ::TabTab::ControllerMethods
  include ::TabTab::ControllerInstanceMethods
end

class ActionView::Base
  include ::TabTab::ViewHelpers
end