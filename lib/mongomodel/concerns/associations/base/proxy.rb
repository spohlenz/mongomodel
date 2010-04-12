module MongoModel
  module Associations
    module Base
      class Proxy
        alias_method :proxy_respond_to?, :respond_to?
        alias_method :proxy_extend, :extend

        instance_methods.each { |m| undef_method m unless m =~ /(^__|^nil\?$|^send$|proxy_|^object_id$)/ }

        attr_reader :association

        def initialize(association)
          @association = association
        end
  
        def target=(new_target)
          @target = new_target
          loaded!
          @target
        end

        def target
          load_target
          @target
        end

        def loaded?
          @loaded
        end

        def loaded!
          @loaded = true
        end

        def reset
          @loaded = false
          @target = nil
        end

        def respond_to?(*args)
          proxy_respond_to?(*args) || target.respond_to?(*args)
        end

      private
        def method_missing(*args, &block)
          target.send(*args, &block)
        end

        def load_target
          @target = association.find_target unless loaded?
          loaded!
        rescue MongoModel::DocumentNotFound
          reset
        end
      end
    end
  end
end
