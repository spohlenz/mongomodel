# require 'thor-ext'
require 'rails/generators/base'

module MongoModel
  module Generators
    class ConfigGenerator < Rails::Generators::Base
      # include ThorExtensions
      source_root File.expand_path('../templates', __FILE__)

      argument :database, :type => :string, :default => 'mongo_db_default'

      def create_files
        template "mongomodel.yml" , "config/mongomodel.yml"
      end

      # def self.source_root
      #   @source_root ||= File.expand_path('../templates', __FILE__)
      # end

      def self.banner
        "#{$0} mongomodel:#{generator_name} #{self.arguments.map{ |a| a.usage }.join(' ')} [options]"
      end

      
    end
  end
end
