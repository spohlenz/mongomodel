require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/except'

module MongoModel
  class Configuration
    def initialize(options)
      case options
      when Hash
        @options = DEFAULTS.merge(options).stringify_keys
      when String
        super(parse(options))
      end
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
    
    def username
      @options['username']
    end
    
    def password
      @options['password']
    end
    
    def establish_connection
      @connection ||= Mongo::Connection.new(host, port, connection_options)
      @database = @connection.db(database)
      @database.authenticate(username, password) if username.present?
      @database
    end
    
    def use_database(database)
      @options['database'] = database
      establish_connection
    end
    
    def connection_options
      @options.except('host', 'port', 'database', 'username', 'password').symbolize_keys
    end
    
    DEFAULTS = {
      'host'      => 'localhost',
      'port'      => 27017,
      'database'  => 'mongomodel-default',
      'pool_size' => 5,
      'timeout'   => 5,
      'logger'    => MongoModel.logger
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
