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

begin
  require 'jeweler'
  require File.dirname(__FILE__) + "/lib/mongomodel/version"
  
  Jeweler::Tasks.new do |gem|
    gem.name = "mongomodel"
    gem.summary = "MongoDB ORM for Ruby/Rails"
    gem.description = "MongoModel is a MongoDB ORM for Ruby/Rails similar to ActiveRecord and DataMapper."
    gem.email = "sam@sampohlenz.com"
    gem.homepage = "http://www.mongomodel.org"
    gem.authors = ["Sam Pohlenz"]
    gem.version = MongoModel::VERSION

    gem.add_dependency('activesupport', '~> 3.0.0')
    gem.add_dependency('activemodel', '~> 3.0.0')
    gem.add_dependency('mongo', '~> 1.0.7')
    gem.add_development_dependency('rspec', '>= 1.3.0')
  end
  
  Jeweler::GemcutterTasks.new  
rescue LoadError
  STDERR.puts "Jeweler not available. Install it with: gem install jeweler"
end
