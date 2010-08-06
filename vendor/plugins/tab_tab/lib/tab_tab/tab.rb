module TabTab
  class Tab #:nodoc:
    attr_accessor :nested_path #:nodoc:

    def ==(other) #:nodoc:
      self.nested_path == other.nested_path
    end

    # Creates a new Tab object. Takes a symbol (or string), or an array of
    # symbols, or a single key hash of single key hashes, where both keys and
    # values are symbols. Like so:
    #
    # Tab.new :invoices
    #
    # Or, for nested tabs:
    #
    # Tab.new { :administration => { :requests => :pending_approval }
    # Tab.new [ 'administration', 'requests', 'pending_approval' ]
    #
    def initialize(*args)
      if args.flatten.first.is_a? Hash
        self.nested_path = []

        deep_keys = args.flatten.first.clone

        while deep_keys.is_a? Hash
          next_key = deep_keys.keys.first
          self.nested_path << next_key.to_s
          deep_keys = deep_keys[next_key]
        end

        self.nested_path << deep_keys.to_s # Last key

      else
        self.nested_path = args.flatten.collect { |p| p.to_s }
      end
    end

    # Returns the auto-generated HTML id for the tab html element, by joining
    # the nested tab IDs with underscores, and adding '_tab' at the end.
    #
    def html_id
      ([ self.nested_path ] + [ 'tab' ]).join '_'
    end

    # Returns the auto-generated name (caption) for a tab, inferring it from
    # the last part of a nested tab literal.
    #
    def name
      self.nested_path.last.titlecase
    end

    # Deep, nested tabs activate themselves and their parents. For example:
    #
    # messages_tab = Tab.new :messages
    # unread_tab   = Tab.new :messages => :unread
    #
    # unread_tab.activates?(unread_tab)   => true
    # unread_tab.activates?(messages_tab) => true
    #
    # The idea being that when the current tab is the 'unread messages' one,
    # both the unread messages tab and the messages tab will appear as active
    # tabs, since one is nested under the other.
    #
    def activates?(other)
      other.nested_path == self.nested_path[0..other.nested_path.size-1]
    end
  end
end