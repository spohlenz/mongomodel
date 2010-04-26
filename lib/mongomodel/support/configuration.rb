require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/except'

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
      @connection ||= Mongo::Connection.new(host, port, connection_options)
      @database = @connection.db(database)
    end
    
    def use_database(database)
      @options['database'] = database
      establish_connection
    end
    
    def connection_options
      @options.except('host', 'port', 'database').symbolize_keys
    end
    
    DEFAULTS = {
      'host'      => 'localhost',
      'port'      => 27017,
      'database'  => 'mongomodel-default',
      'pool_size' => 5,
      'timeout'   => 5
    }
    
    def self.defaults
      new({})
    end
  end
end
