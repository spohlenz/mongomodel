require 'rake/rdoctask'

task :default => :spec

begin
  require 'spec/rake/spectask'
  desc 'Run the specs'
  Spec::Rake::SpecTask.new(:spec) do |t|
    t.libs << 'lib'
    t.spec_opts = ['--options', "#{File.expand_path(File.dirname(__FILE__))}/spec/spec.opts"]
  end
  
  namespace :spec do
    desc "Run specs in nested documenting format"
    Spec::Rake::SpecTask.new(:doc) do |t|
      t.libs << 'lib'
      t.spec_opts = ['--options', "#{File.expand_path(File.dirname(__FILE__))}/spec/specdoc.opts"]
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

desc "Generate documentation"
Rake::RDocTask.new(:doc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('lib')
end

require 'bundler'
Bundler::GemHelper.install_tasks
