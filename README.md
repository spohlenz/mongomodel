MongoModel
==========

MongoModel is a Ruby ORM for interfacing with [MongoDB](http://www.mongodb.org/) databases.


Installation
============

MongoModel is distributed as a gem. Install with:

    gem install mongomodel

For performance, you should probably also install the BSON C extensions:

    gem install bson_ext


Using with Rails 3
==================

Setup config/mongomodel.yml:

    rails generate mongo_model:config DATABASENAME

Generating a model/document:

    rails generate model Article title:string body:string published_at:time approved:boolean 

Generating an embedded document:

    rails generate model Chapter title:string body:string -E


Sample Usage
============

    require 'mongomodel'
    
    MongoModel.configuration = { 'host' => 'localhost', 'database' => 'mydb' }
    
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
    