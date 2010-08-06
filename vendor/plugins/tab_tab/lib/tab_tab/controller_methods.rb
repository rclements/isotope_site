module TabTab
  module ControllerMethods
    # Called from your controllers to specify the current tab for this
    # controller/action. Like so:
    #
    #   tab :foo
    #
    # Or, for nesting:
    #
    #   tab :administration => { :requests => :pending_approval }
    #   tab :administration, :requests, :pending_approval
    #
    def tab(*tab_literal)
      # FIXME: This is probably not all that threadsafe.
      tab_literal.any? ? @_tab = Tab.new(tab_literal) : @_tab
    end
  end
end
