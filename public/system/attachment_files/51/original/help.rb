STDOUT.print <<HELP

  Mr. Guid Help
  -------------

  Usage: ruby mr_guid.rb [options] script [arguments]

  Options:
    -l[=[host:]port], --local[=[host:]port]
        Starts debugging script on [[host:]port]
        (use this if you want to debug script on non-default
        port or host)

    -r[=[host:]port], --remote[=[host:]port]
        Debugs remote script running on [[host:]port] or
        default localhost:3001

  In order to debug remotely, the command
    ruby -r gdebug.rb script [arguments] [options]
      with options being
        -r[=[host:]port], --remote[=[host:]port]
  must be issued separately. Default is localhost:3001

  Note: If debugging remotely, source files will be
  transferred over the connection, making local copies
  unnecessary.
  Also: [options] can appear anywhere after file in either
  gdebug or mr_guid. Order does not matter.

  Examples:
    ruby mr_guid.rb my_script.rb
        starts debugging my_script normally (localhost:3001)

    ruby mr_guid.rb -l=5000 my_script.rb
        starts debugging my_script on localhost:5000

    ruby -r gdebug.rb my_script.rb -r
    [elsewhere on same host]
    ruby mr_guid.rb -r
        starts debugging my_script remotely over default
        localhost:3001

    [on 192.168.0.10]
    ruby -r gdebug.rb my_script.rb -r=5000
    [on 192.168.0.11]
    ruby mr_guid.rb -r=192.168.0.10:5000
        starts debugging my_script remotely on
        192.168.0.10:5000

HELP