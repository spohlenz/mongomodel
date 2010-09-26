module MongoModel
  class Railtie < Rails::Railtie

    config.generators.orm :mongo_model, :migration => false

    rake_tasks do
      load "mongomodel/tasks/database.rake"
    end
    
    initializer "mongomodel.logger" do
      MongoModel.logger ||= ::Rails.logger
    end
    
    initializer "mongomodel.rescue_responses" do
      ActionDispatch::ShowExceptions.rescue_responses['MongoModel::DocumentNotFound'] = :not_found
    end
    
    initializer "mongomodel.database_configuration" do |app|
      require 'erb'
      
      config = Pathname.new(app.paths.config.to_a.first).join("mongomodel.yml")
      
      if File.exists?(config)
        mongomodel_configuration = YAML::load(ERB.new(IO.read(config)).result)
        MongoModel.configuration = mongomodel_configuration[Rails.env]
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
