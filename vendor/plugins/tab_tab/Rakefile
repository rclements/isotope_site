require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

begin
  require 'rcov/rcovtask'
rescue LoadError
  nil
end

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the tab_tab plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the tab_tab plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'tab_tab'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

if defined?(Rcov)
  namespace :test do
    Rcov::RcovTask.new do |t|
      t.libs       << 'test'
      t.test_files = FileList[ 'test/*_test.rb' ]
      t.output_dir = 'test/coverage'
      t.verbose    = false
      t.rcov_opts  << '-x /Library/ --html --rails'
    end
  end

  # Compatibility with old task:
  task :rcov => 'test:rcov' do
    system 'open test/coverage/index.html' if PLATFORM['darwin']
  end
end