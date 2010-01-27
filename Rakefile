require 'spec/rake/spectask'
require 'rake/rdoctask'

task :default => :spec

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
    gem.homepage = "http://github.com/spohlenz/mongomodel"
    gem.authors = ["Sam Pohlenz"]
    gem.version = MongoModel::VERSION

    gem.add_dependency('activesupport', '>= 3.0.pre')
    gem.add_dependency('activemodel', '>= 3.0.pre')
    gem.add_dependency('mongo', '>= 0.18.3')
  end
  
  Jeweler::GemcutterTasks.new  
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
