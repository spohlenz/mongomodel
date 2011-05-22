# -*- encoding: utf-8 -*-
require File.expand_path("../lib/mongomodel/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "mongomodel"
  s.version     = MongoModel::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Sam Pohlenz"]
  s.email       = ["sam@sampohlenz.com"]
  s.homepage    = "http://www.mongomodel.org"
  s.summary     = "MongoDB ORM for Ruby/Rails"
  s.description = "MongoModel is a MongoDB ORM for Ruby/Rails similar to ActiveRecord and DataMapper."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "mongomodel"
  
  s.add_dependency "activesupport", "~> 3.1.0.rc1"
  s.add_dependency "activemodel",   "~> 3.1.0.rc1"
  s.add_dependency "mongo",         "~> 1.3.1"
  s.add_dependency "will_paginate", "~> 2.3.15"

  if !defined?(RUBY_ENGINE) || (RUBY_ENGINE == 'ruby' && RUBY_VERSION < '1.9.0')
    s.add_dependency "SystemTimer", "~> 1.2.3"
  end

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rspec",   "= 1.3.0"

  s.files        = `git ls-files`.split("\n")
  s.require_path = 'lib'
end
