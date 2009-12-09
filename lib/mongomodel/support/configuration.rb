require 'active_support/core_ext/hash/keys'

module MongoModel
  class Configuration
    def initialize(options)
      @options = DEFAULTS.merge(options).stringify_keys
    end
    
    def host
      @options['host']
    end
    
    def port
      @options['port']
    end
    
    def database
      @options['database']
    end
    
    def establish_connection
      Mongo::Connection.new(host, port).db(database)
    end
    
    DEFAULTS = {
      'host'     => 'localhost',
      'port'     => 27017,
      'database' => 'mongomodel-default'
    }
    
    def self.defaults
      new({})
    end
  end
end
