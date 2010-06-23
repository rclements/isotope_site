#!/usr/bin/ruby

if ARGV[0] == "--help" or ARGV[0] == "help"
  print <<HELP
Usage: ./install.rb [options]
  This will install the mr_guid executable in /usr/local/bin by
  default, but it can be changed with the --prefix option.

Options:
  --prefix=[install_path]  path to install mr_guid executable to
HELP
  exit
end

abs_path = File::expand_path( File::dirname(__FILE__) )

path = ( ARGV.size > 0 and ARGV[0].strip =~ /--prefix=(.+)/ ) ? $1 : '/usr/local/bin'

file = path + '/mr_guid'
begin
  File::unlink(file) if File::exist?(file)
  f = File.new(file, "w")
    f.print("#!/usr/bin/ruby\n\n")
    f.print("`ruby #{abs_path}/mr_guid.rb \#{ARGV.join(' ')}`")
    f.chmod(0755)
  f.close
  puts 'Mr. Guid was installed successfully'
rescue
  puts "Sorry. You don't have permission to install to '#{path}'"
end