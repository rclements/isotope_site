module TabTab
  module ControllerInstanceMethods #:nodoc:
    def current_tab #:nodoc:
      self.tab || self.class.tab || Tab.new(self.controller_name)
    end
  end
end