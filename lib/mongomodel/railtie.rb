module MongoModel
  class Railtie < Rails::Railtie
    def self.rescue_responses
      { 'MongoModel::DocumentNotFound' => :not_found }
    end
    
    if config.action_dispatch.rescue_responses
      config.action_dispatch.rescue_responses.merge!(rescue_responses)
    end
    
    config.app_generators.orm :mongo_model, :migration => false

    rake_tasks do
      load "mongomodel/tasks/database.rake"
    end
    
    console do
      MongoModel.logger = Logger.new(STDERR)
    end
    
    initializer "mongomodel.logger" do
      MongoModel.logger ||= ::Rails.logger
    end
    
    initializer "mongomodel.rescue_responses" do
      unless config.action_dispatch.rescue_responses
        ActionDispatch::ShowExceptions.rescue_responses.update(self.class.rescue_responses)
      end
    end
    
    initializer "mongomodel.database_configuration" do |app|
      require 'erb'
      
      config = Rails.root.join("config", "mongomodel.yml")
      
      if File.exists?(config)
        mongomodel_configuration = YAML::load(ERB.new(IO.read(config)).result)
        MongoModel.configuration = mongomodel_configuration[Rails.env]
      end
    end
    
    # Expose database runtime to controller for logging.
    initializer "mongomodel.log_runtime" do |app|
      require "mongomodel/railties/controller_runtime"
      ActiveSupport.on_load(:action_controller) do
        include MongoModel::Railties::ControllerRuntime
      end
    end
    
    initializer "mongomodel.passenger_forking" do |app|
      if defined?(PhusionPassenger)
        PhusionPassenger.on_event(:starting_worker_process) do |forked|
          MongoModel.database.connection.connect if forked
        end
      end
    end
  end
end
