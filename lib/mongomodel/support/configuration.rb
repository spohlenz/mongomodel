require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/except'

module MongoModel
  class Configuration
    DEFAULTS = {
      'host'         => 'localhost',
      'port'         => 27017,
      'database'     => 'mongomodel-default',
      'pool_size'    => 5,
      'pool_timeout' => 5
    }

    attr_reader :options

    def initialize(options)
      @options = DEFAULTS.merge(options).stringify_keys
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
    
    def replicas
      options['replicas'] || []
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
      if replicas.any?
        @connection ||= Mongo::MongoReplicaSetClient.new(replicas, connection_options)
      else
        @connection ||= Mongo::MongoClient.new(host, port, connection_options)
      end
    end
    
    def connection_options
      options.except('host', 'port', 'database', 'username', 'password', 'replicas').symbolize_keys
    end
    
    def self.defaults
      new({})
    end
  end

  class URIConfiguration
    def initialize(uri)
      @uri = uri
    end

    def host
      parser.host
    end

    def port
      parser.port
    end

    def database
      parser.connection_options[:db_name]
    end

    def establish_connection
      @database = connection.db
    end

    def connection
      @connection ||= parser.connection({})
    end

    def parser
      @parser ||= Mongo::URIParser.new(@uri)
    end
  end
end
