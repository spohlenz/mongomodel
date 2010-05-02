module MongoModel
  class Railtie < Rails::Railtie
    initializer "mongomodel.logger" do
      MongoModel.logger ||= ::Rails.logger
    end
    
    initializer "mongomodel.rescue_responses" do
      ActionDispatch::ShowExceptions.rescue_responses['MongoModel::DocumentNotFound'] = :not_found
    end
    
    initializer "mongomodel.database_configuration" do |app|
      require 'erb'
      
      config = Pathname.new(app.paths.config.to_a.first).join("mongomodel.yml")
      mongomodel_configuration = YAML::load(ERB.new(IO.read(config)).result)
      
      MongoModel.configuration = mongomodel_configuration[Rails.env]
    end
  end
end
