require 'rails/generators/base'

module MongoModel
  module Generators
    class ConfigGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      argument :database, :type => :string, :default => 'mongomodel_default'

      def create_files
        template "mongomodel.yml" , "config/mongomodel.yml"
      end

      def self.banner
        "rails generate mongo_model:#{generator_name} #{self.arguments.map{ |a| a.usage }.join(' ')} [options]"
      end
    end
  end
end
