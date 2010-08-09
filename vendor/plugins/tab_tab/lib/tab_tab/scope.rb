module TabTab
  class Scope #:nodoc:
    attr_accessor :view #:nodoc:
    attr_accessor :path #:nodoc:

    def tab(url, tab_literal, opts = nil) #:nodoc:
      view.tab(url, (path + Tab.new(tab_literal).nested_path), opts)
    end
  end
end