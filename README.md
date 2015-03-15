MongoModel
==========

MongoModel is a Ruby ORM for interfacing with [MongoDB](http://www.mongodb.org/) databases.

[![Build Status](https://travis-ci.org/spohlenz/mongomodel.png?branch=master)](https://travis-ci.org/spohlenz/mongomodel)


Installation
============

MongoModel is distributed as a gem. Install with:

    gem install mongomodel

For performance, you should probably also install the BSON C extensions:

    gem install bson_ext


Using with Rails
================

Add MongoModel to your Gemfile (and run `bundle install`):

    gem 'mongomodel'

Create the configuration file `config/mongomodel.yml`:

    rails generate mongo_model:config DATABASENAME

Generating a model/document:

    rails generate model Article title:string body:string published_at:time approved:boolean 

Generating an embedded document:

    rails generate model Chapter title:string body:string -E


Sample Model
============

    class Article < MongoModel::Document
      property :title, String, :default => 'Untitled'
      property :body, String
      property :published_at, Time, :protected => true
      property :approved, Boolean, :default => false, :protected => true
      
      timestamps!
      
      validates_presence_of :title, :body
      
      belongs_to :author, :class => User
      
      scope :published, where(:published_at.ne => nil)
    end
    

Configuration
=============

MongoModel can be configured similarly to ActiveRecord by creating/editing `config/mongomodel.yml`. The most basic configuration might look like:

```yaml
development:
  database: mymongodbname
  host: localhost
  port: 27017
```

The config file also supports specifying the username, password, pool_size, password and replicas. Running `rails generate mongo_model:config DATABASENAME` will generate a basic config file for you.

Using Replica Sets
------------------

When working with replica sets, replace the host/port configuration with an array of replicas (`host:port`):

```yaml
production:
  database: database_name
  replicas:
    - some.host.com:27017
    - another.host.com:27017
  username: username
  password: password
```
