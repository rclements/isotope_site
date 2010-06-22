#!/usr/bin/ruby

# Mr. Guid - Mitchell's Ruby GUI Debugger
# This application is free software; you can redistribute
# it and/or modify it under the terms of the Ruby license
# defined in the COPYING file

# Copyright (c) 2006 Mitchell Foral. All rights reserved.

require 'gtk2'
require 'libglade2'
require 'socket'

Gtk.init

class Debugger

  def initialize(file, host, port, remote)
    unless file.nil? or FileTest.exist? file
      STDOUT.print "File to debug does not exist"
      exit
    end

    @debug_file = file
    @host   = host
    @port   = port
    @remote = remote
    @glade  = GladeXML.new( File.join( File::dirname(__FILE__), 'gdebug.glade' ) ) { |handler| method(handler) }

    @source = @glade['source']
    @output = @glade['output']
    @status = @glade['status']

    @source_models = Hash.new
    @breakpoints   = Array.new

    renderer = Gtk::CellRendererText.new
    renderer.family = 'monospace'

    # setup source view
    ['B', 'Line', 'Code'].each_with_index do |label, i|
      @source.append_column( Gtk::TreeViewColumn.new(label, renderer, :text => i) )
      @source.get_column(i).set_property('resizable', true)
    end
    @source.search_column = 1 # search by line number

    # setup variables view
    ['Name', 'Value'].each_with_index do |label, i|
      @glade['local_variables'].append_column( Gtk::TreeViewColumn.new(label, renderer, :text => i) )
      @glade['global_variables'].append_column( Gtk::TreeViewColumn.new(label, renderer, :text => i) )
      @glade['instance_variables'].append_column( Gtk::TreeViewColumn.new(label, renderer, :text => i) )
      @glade['local_variables'].get_column(i).set_property('resizable', true)
      @glade['global_variables'].get_column(i).set_property('resizable', true)
      @glade['instance_variables'].get_column(i).set_property('resizable', true)
    end
    @glade['local_variables'].model  = Gtk::ListStore.new(String, String)
    @glade['global_variables'].model = Gtk::ListStore.new(String, String)
    @glade['instance_variables'].model = Gtk::ListStore.new(String, String)

    # setup threads view
    ['#', 'Name', 'Status'].each_with_index do |label, i|
      @glade['threads'].append_column( Gtk::TreeViewColumn.new(label, renderer, :text => i) )
      @glade['threads'].get_column(i).set_property('resizable', true)
    end
    @glade['threads'].model = Gtk::ListStore.new(String, String, String)

    # setup stack view
    ['C', '#', 'Frame'].each_with_index do |label, i|
      @glade['stack'].append_column( Gtk::TreeViewColumn.new(label, renderer, :text => i) )
      @glade['stack'].get_column(i).set_property('resizable', true)
    end
    @glade['stack'].model = Gtk::ListStore.new(String, String, String)
    @glade['stack'].search_column = 2

    # setup methods view
    @glade['methods'].append_column( Gtk::TreeViewColumn.new('Name', renderer, :text => 0) )
    @glade['methods'].get_column(0).set_property('resizable', true)
    @glade['methods'].model = Gtk::ListStore.new(String)

    load_source(@debug_file)

    @running = false
    start(nil) # start the debugger
  end

  def start(widget)
    return if @running

    Thread.abort_on_exception = true
    unless @remote
      begin
        gdebug = File.join( File::dirname(__FILE__), 'gdebug' )
        ARGV.shift if ARGV.first == @debug_file
        @debug_thread = Thread.new do
          `ruby -r #{gdebug} #{@debug_file} --mr_guid_client --port=#{@port} #{ARGV.join(' ')}`
        end
        @server.close if defined? @server and !@server.closed?
        @server = TCPServer.new(@port)
        @socket = @server.accept
        @output_thread = Thread.new { process_output }
      rescue
        display_output("Sorry, port #{@port} is in use by another process\n")
        return
      end
    else
      begin
        @socket = TCPSocket.new(@host, @port)
        @output_thread = Thread.new { process_output }
      rescue
        display_output("No debug process detected on #{@host}:#{@port}. It probably needs to be restarted.\n")
        return
      end
    end

    Thread.new { restore_all_breakpoints }.join unless @breakpoints.empty?

    display_output("Debugger started\n")
    update_status('Debugging'); @running = true
  end

  def stop(widget)
    issue_command('quit') unless widget.nil? # issue if user wants to stop, not the system
    @output_thread.kill if defined? @output_thread
    @debug_thread.kill if defined? @debug_thread
    @server.close if defined? @server and !@server.closed?
    @socket.close if defined? @socket and !@socket.closed?
    if @remote
      begin # issue command only if server is alive
        socket = TCPSocket.open(@host, @port)
        socket.puts 'quit'
        socket.close
      rescue
        # server is not alive
      end
    end

    output = widget ? "Debugger stopped" : "Debugging finished"
    display_output(output + "\n")
    update_status(output); @running = false
  end

  def running?
    return true if @running
    display_message_dialog("The debugger must be initialized first.")
    return false
  end

  def issue_command(cmd, try_again=nil)
    return if !@running && try_again.nil?
    begin
      @socket.puts cmd
    rescue
      if try_again.nil? then stop(nil); return end
      num_retries ||= 0
      if num_retries < 10
        num_retries += 1
        sleep(0.1)
        retry
      end
      display_output("Failed to issue command '#{cmd}'\n")
    end
  end

  def process_output
    while msg = @socket.gets
      case msg
      when /^:local_vars/
        update_volatile( @glade['local_variables'].model, /(.+?)?=>(.+)/ )
      when /^:global_vars/
        update_volatile( @glade['global_variables'].model, /(.+?)?=>(.+)/ )
      when /^:instance_vars/
        update_volatile( @glade['instance_variables'].model, /(.+?)?=>(.+)/ )
      when /^:methods/
        update_volatile( @glade['methods'].model, /(.+)/ )
      when /^:threads/
        update_volatile( @glade['threads'].model, /.(\d+)\s#<(Thread:\dx[\d|a-f]+)\s(.+)>/ )
      when /^:stack/
        update_volatile( @glade['stack'].model, /(>\s)?#(\d+)\s(.+)/ )
      when /^:file\s(.+):(\d+):(\d+)/
        file, size, line = $1.strip, $2.to_i, $3.to_i
        load_source( file, @socket.read(size) )
        update_source_position(file, line - 1)
      when /(>\s)?#(\d+)\s(.+)/
        issue_command('frame')
      when /^Set\sbreakpoint\s(\d+)\sat\s(.+):(\d+)/
        @breakpoints[$1.to_i] = [$2, $3]
      when /^#\d+:.+:\d:.*:.:\s.+/
        # trace
      when /(.+)::(\d+)::.*/
        update_source_position( $1, $2.to_i - 1 )
        update_volatiles_view
      when /.+:\d+:.+/ # exception
        display_output msg
        hide_object_window(nil, nil)
      else
        display_output msg
      end
    end
  end

  def display_output(msg)
    buffer = @output.buffer
    buffer.text += msg
    @output.scroll_to_iter( buffer.get_iter_at_line(buffer.line_count), 0, false, 0, 0 )
  end

  # ----- Dialogs ----- #

  def display_message_dialog(msg)
    message = Gtk::MessageDialog.new(
                nil, Gtk::Dialog::MODAL,
                Gtk::MessageDialog::INFO,
                Gtk::MessageDialog::BUTTONS_OK,
                msg
              )
    message.run
    message.destroy
  end

  def get_input(title, label, default=nil)
    dialog = Gtk::Dialog.new( title, nil, Gtk::Dialog::MODAL,
              [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_REJECT],
              [Gtk::Stock::OK,     Gtk::Dialog::RESPONSE_ACCEPT] )
    dialog.default_response = Gtk::Dialog::RESPONSE_ACCEPT

    label = Gtk::Label.new(label).show
    entry = Gtk::Entry.new.show
    entry.text = default unless default.nil?
    entry.activates_default = true

    hbox = Gtk::HBox.new(false, 5).show
    hbox.border_width = 5
    hbox.add(label); hbox.add(entry)
    dialog.vbox.add(hbox)

    response = dialog.run
    input = entry.text
    dialog.destroy

    return nil if response == Gtk::Dialog::RESPONSE_REJECT
    return ( input.strip.empty? ) ? nil : input
  end

  # ----- Basic Commands ----- #

  def quit(widget) stop(nil); Gtk.main_quit end

  def continue(widget)
    issue_command('cont')
    update_status('Continuing...')
  end

  def step_in(widget) issue_command('step') end

  def step_over(widget) issue_command('next') end

  def execute(widget=nil)
    return if not running? or @glade['command'].text.strip.empty?
    issue_command( @glade['command'].text )
  end

  # ----- Source View ----- #

  def load_source(file, source=nil)
    return if file.nil? or file == ""
    if @source_models.has_key? file
      @source.model = @source_models[file]
    else
      if @remote and source.nil?
        issue_command("file #{file}")
        return
      end
      source = IO.readlines(file) unless @remote
      list_store = Gtk::ListStore.new(String, Integer, String)
      source.each_with_index do |line, index|
        iter = list_store.append
        iter[0] = ''          # breakpoint set?
        iter[1] = index + 1   # line number
        iter[2] = line.chomp  # source code line
      end
      @source_models[file] = list_store
      @source.model = list_store
    end
    @glade['source_file_name'].text = File.basename(file)
  end

  def menu_load_source(widget)
    file = get_input("Load Source File", 'File:')
    file = File.join( File.dirname(file), File.basename(file) )
    if @remote == false and !FileTest.exist?(file)
      display_message_dialog("File '#{file}' does not exist.")
      return
    end
    load_source(file)
  end

  def show_next_file(widget) get_file(:next) end

  def show_previous_file(widget) get_file(:previous) end

  def get_file(skip)
    return if @source_models.size == 1
    files = @source_models.keys.sort
    files.each_with_index do |file, index|
      if @source_models[file] == @source.model
        if skip == :previous
          source_file = files[index - 1]
        else
          source_file = ( index == files.size - 1 ) ? files[0] : files[index + 1]
        end
        load_source(source_file)
        break
      end
    end
  end

  def update_source_position(file, line)
    begin
      load_source(file) unless @source.model == @source_models[file] and @source.model != nil
      path = Gtk::TreePath.new(line.to_s)
      @source.set_cursor(path, nil, false)
      unless @breakpoints.index( [ file, (line + 1).to_s ] ).nil?
        update_status("At breakpoint: #{file}:#{line + 1}")
      else
        update_status("Debugging '#{file}' Line: #{line + 1}")
      end
    rescue
      STDOUT.print "Bad line to update: #{line}"
    end
  end

  # ----- Breakpoints ----- #

  def toggle_breakpoint(widget, path, column)
    return unless running?
    filename = @source_models.index(@source.model)

    # toggle status in breakpoint column
    iter = @source.model.get_iter(path)
    breakpoint = @source.model.get_value(iter, 0)
    breakpoint = ( breakpoint == '*' ) ? '' : '*'
    command    = ( breakpoint == '*' ) ? "break #{filename}:" : 'delete '
    @source.model.set_value(iter, 0, breakpoint)

    num = (path.to_s.to_i + 1).to_s # treeview counts from zero
    if breakpoint == ''
      num = @breakpoints.index( [ @source_models.index(@source.model), num ] ).to_s
      @breakpoints[num.to_i] = nil
    end
    issue_command(command + num)
  end

  def menu_set_breakpoint(widget)
    line = get_input("Set Breakpoint", "Line Number:")
    return if line.nil?
    begin
      path = Gtk::TreePath.new( (line.to_i - 1).to_s )
      @source.set_cursor(path, nil, false)
      toggle_breakpoint(nil, path, nil)
    rescue
      display_message_dialog("Please enter a valid line number.")
    end
  end

  def delete_all_breakpoints(widget)
    issue_command('delete')
    @source_models.each_value do |model|
      model.each do |model, path, iter|
        model.set_value(iter, 0, '') if model.get_value(iter, 0) == '*'
      end
    end
    @breakpoints = []
    display_output("All Breakpoints Deleted\n")
  end

  # preserve breakpoints across debug sessions
  def restore_all_breakpoints
    @breakpoints.each do |breakpoint|
      next if breakpoint.nil? or breakpoint.empty?
      file, line = breakpoint
      issue_command("break #{file}:#{line}", true)
    end
  end

  # ----- Variables ----- #

  def popup_variable_menu(widget, event)
    return unless event.button == 3
    @glade['menu_variables'].submenu.popup(nil, nil, event.button, event.time)
  end

  def menu_variable_view(widget)
    case @glade['volatiles'].page
      when 0: view = @glade['local_variables']
      when 1: view = @glade['global_variables']
    end
    return if view.nil?
    variable_view(view)
  end

  def variable_view(widget, path=nil, column=nil)
    return unless running?
    path = widget.cursor[0] if path.nil?
    unless path
      display_message_dialog("Please select a variable to view.")
      return
    end
    iter = widget.model.get_iter(path)
    variable, value = iter[0], iter[1]
    if value =~ /^#<.+:\dx[\d|a-f]+\s(.+)>/ or variable =~ /(@.+)/
      unless $1.scan(/@/).empty?
        variable.gsub!(/@/, "")
        if widget == @glade['instance_variables']
          variable = @glade['object_name'].text + '.' + variable # chain if needed
        end
        issue_command("var instance #{variable}")
        setup_object_window(variable, 0)
        return
      end
    end
    issue_command("method instance #{variable}")
    setup_object_window(variable, 1, value)
  end

  # ----- Threads ----- #

  def popup_thread_menu(widget, event)
    return unless event.button == 3
    @glade['menu_threads'].submenu.popup(nil, nil, event.button, event.time)
  end

  def menu_thread_stop(widget)
    thread_action('stop', "Please select a thread to stop.")
  end

  def menu_thread_resume(widget)
    thread_action('resume', "Please select a thread to resume.")
  end

  def menu_set_thread_stop(widget)
    num = get_input("Resume Thread", "Thread Number:")
    return if num.nil?
    thread_action( 'stop', "Please enter a valid thread number.", num.to_i )
  end

  def menu_set_thread_resume(widget)
    num = get_input("Resume Thread", "Thread Number:")
    return if num.nil?
    thread_action( 'resume', "Please enter a valid thread number.", num.to_i )
  end

  def thread_action(action, dialog_msg, thread_num=nil)
    return unless running?
    unless thread_num
      path = @glade['threads'].cursor[0]
      unless path
        display_message_dialog(dialog_msg)
        return
      end
      iter = @glade['threads'].model.get_iter(path)
      thread_num = @glade['threads'].model.get_value(iter, 0).to_i
    else
      unless thread_num > 0
        display_message_dialog(dialog_msg)
        return
      end
    end
    issue_command("thread #{action} #{thread_num}")
  end

  # ----- Stacks ----- #

  def stack_up(widget) issue_command('up') end

  def stack_down(widget) issue_command('down') end

  def stack_finish(widget) issue_command('finish') end

  def menu_set_stack(widget)
    stack_num = get_input("Move To Stack", "Stack Number:")
    return if stack_num.nil?
    @glade['stack'].model.each do |model, path, iter|
      if iter[1] == stack_num
        @glade['stack'].set_cursor(path, nil, false)
        set_stack(widget, path, nil)
        return
      end
    end
    display_message_dialog("Please enter an existing stack number.")
  end

  def set_stack(widget, path, column)
    return unless running?
    new_stack = path
    current_stack = nil
    @glade['stack'].model.each do |model, path, iter|
      if iter[0] == '>'
        current_stack = path
        break
      end
    end
    moves = new_stack.to_s.to_i - current_stack.to_s.to_i
    command = ( moves > 0 ) ? 'up ' : 'down '
    issue_command( command + moves.abs.to_s )
  end

  # ----- Volatiles Views ----- #

  def update_volatiles_view(*args)
    page = ( args.empty? ) ? @glade['volatiles'].page : args[2]
    case page
      when 0: issue_command('var local')
      when 1: issue_command('var global')
      when 2: issue_command('thread list')
      when 3: issue_command('frame')
    end
    if @glade['object_window'].visible?
      page = ( args.empty? ) ? @glade['object_notebook'].page : args[2]
      object_name = @glade['object_name'].text
      case page
        when 0: issue_command("var instance #{object_name}")
        when 1: issue_command("method instance #{object_name}")
      end
    end
  end

  def update_volatile(model, pattern)
    model.clear
    get_volatiles(pattern) do |volatile|
      iter = model.append
      volatile.captures.each_with_index do |value, i|
        value.strip! unless value.nil?
        iter[i] = value.gsub(/\s@/, "\n@") # multiple lines are easier to read
      end
    end
  end

  def get_volatiles(pattern)
    while msg = @socket.gets
      break if msg =~ /^:end/
      if match = pattern.match(msg)
        yield match
      else
        display_output msg # error
        break
      end
    end
  end

  # ----- Object Window ----- #

  def setup_object_window(object, page, text="")
    @glade['object_window'].visible = true
    @glade['object_name'].text = object
    @glade['object_notebook'].page = page
    @glade['instance_variables'].model.clear
    @glade['methods'].model.clear
    @glade['new_object_value_label'].text = "New value for '#{object}':"
    @glade['new_object_value'].text = text
    @glade['new_object_value'].grab_focus
  end

  def set_object_value(widget)
    return if @glade['new_object_value'].text.strip.empty?
    issue_command("p #{@glade['object_name'].text} = #{@glade['new_object_value'].text}")
    hide_object_window(nil, nil)
    update_volatiles_view
  end

  def hide_object_window(widget, event)
    @glade['object_window'].visible = false
    return true # don't kill the window, hide it
  end

  # ----- Miscellaneous ----- #

  def clear_output(widget) @output.buffer.text = "" end

  def keyrelease(widget, key)
    return unless key.state.control_mask?
    path = widget.cursor[0]
    widget.set_cursor(path, nil, false)
  end

  def update_status(text) @status.pop(0); @status.push(0, text) end

  def toggle_toolbar_view(widget)
    @glade['toolbar'].visible = widget.active?
  end

  def help(widget) issue_command('help') end

  def about(widget)
    display_message_dialog("Mitchell's Ruby GUI Debugger\nv0.2")
  end

end

if ARGV[0] == '--help' or ARGV[0] == 'help'
  load File.join( File::dirname(__FILE__), "help.rb" )
  exit
end

ARGV.each do |arg|
  next unless arg =~ /(-r|--remote|-l|--local)(=(.*:)?(\d+))?/
  $remote = ( $1 == '-r' or $1 == '--remote' )
  $host = $3.chop if $3
  $port = $4 if $4
  ARGV.delete(arg)
  break
end
$host ||= 'localhost'
$port ||= 3001

if ARGV.size == 0 and $remote == false
  STDOUT.print "Please supply a file to debug.\n"
  exit
end
file = $remote ? nil : ARGV[0]

Debugger.new( file, $host, $port, $remote )
Gtk.main
