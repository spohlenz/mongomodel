require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/except'

module MongoModel
  class Configuration
    def initialize(options)
      set_options!(options)
    end
    
    def host
      options['host']
    end
    
    def port
      options['port']
    end
    
    def database
      options['database']
    end
    
    def username
      options['username']
    end
    
    def password
      options['password']
    end
    
    def establish_connection
      @database = connection.db(database)
      @database.authenticate(username, password) if username.present?
      @database
    end
    
    def use_database(database)
      options['database'] = database
      establish_connection
    end
    
    def connection
      @connection ||= Mongo::MongoClient.new(host, port, connection_options)
    end
    
    def connection_options
      options.except('host', 'port', 'database', 'username', 'password').symbolize_keys
    end
    
    def options
      @options ||= {}
    end
    
    def set_options!(options)
      case options
      when Hash
        @options = DEFAULTS.merge(options).stringify_keys
      when String
        set_options!(parse(options))
      end
    end
    
    DEFAULTS = {
      'host'         => 'localhost',
      'port'         => 27017,
      'database'     => 'mongomodel-default',
      'pool_size'    => 5,
      'pool_timeout' => 5
    }
    
    def self.defaults
      new({})
    end
  
  private
    def parse(str)
      uri = URI.parse(str)
      
      {
        'host'     => uri.host,
        'port'     => uri.port,
        'database' => uri.path.gsub(/^\//, ''),
        'username' => uri.user,
        'password' => uri.password
      }
    end
  end
end
