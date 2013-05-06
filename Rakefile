require 'rubygems'
require 'bundler/setup'

task :default => :spec

begin
  require 'rspec/core/rake_task'
  desc 'Run the specs'
  RSpec::Core::RakeTask.new(:spec) do |t|
    #t.libs << 'lib'
    t.rspec_opts = ['--options', "#{File.expand_path(File.dirname(__FILE__))}/spec/spec.opts"]
  end
  
  namespace :spec do
    desc "Run specs in nested documenting format"
    RSpec::Core::RakeTask.new(:doc) do |t|
      #t.libs << 'lib'
      t.rspec_opts = ['--options', "#{File.expand_path(File.dirname(__FILE__))}/spec/specdoc.opts"]
    end
  end
rescue LoadError
  task :spec do
    STDERR.puts "You must have rspec to run the tests"
  end
  namespace :spec do
    task :doc => :spec
  end
end

begin
  require 'rdoc/task'
  desc "Generate documentation"
  Rake::RDocTask.new(:doc) do |rdoc|
    rdoc.rdoc_dir = 'doc'
    rdoc.options << '--line-numbers' << '--inline-source'
    rdoc.rdoc_files.include('lib')
  end
rescue LoadError
  task :doc do
    STDERR.puts "You must have rdoc to generate the documentation"
  end
end

require 'bundler'
Bundler::GemHelper.install_tasks
