require 'rails/generators/base'

module MongoModel
  module Generators
    class ModelGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)

      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
      
      class_option :timestamps, :type => :boolean, :aliases => "-T", :default => true,  :desc => "Add timestamp fields (created_at, updated_at)"
      class_option :embedded,   :type => :boolean, :aliases => "-E", :default => false, :desc => "Inherit from EmbeddedDocument"

      check_class_collision
      
      def create_model_file
        template 'model.rb', File.join('app/models', class_path, "#{file_name}.rb")
      end
      
      hook_for :test_framework
    end
  end
end
