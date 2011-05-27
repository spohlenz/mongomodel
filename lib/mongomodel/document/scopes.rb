module MongoModel
  module DocumentExtensions
    module Scopes
      extend ActiveSupport::Concern
      
      delegate :current_scope, :to => "self.class"
      
      def initialize(*)
        self.attributes = current_scope.options_for_create
        super
      end
      
      module ClassMethods
        delegate :find, :first, :last, :all, :exists?, :count, :to => :scoped
        delegate :update, :update_all, :delete, :delete_all, :destroy, :destroy_all, :to => :scoped
        delegate :select, :order, :where, :limit, :offset, :from, :paginate, :in_batches, :to => :scoped
        
        def unscoped
          @unscoped ||= MongoModel::Scope.new(self)
        end
        
        def scoped
          current_scope.clone
        end
        
        def scope(name, scope)
          name = name.to_sym
          
          if !scopes[name] && respond_to?(name, true)
            logger.warn "Creating scope :#{name}. " \
                        "Overwriting existing method #{self.name}.#{name}."
          end
          
          scopes[name] = lambda do |*args|
            s = scope.is_a?(Proc) ? scope.call(*args) : scope
            scoped.merge(s)
          end
          
          singleton_class.class_eval do
            define_method(name) do |*args|
              scopes[name].call(*args)
            end
          end
        end
        
        def default_scope(scope)
          reset_current_scopes
          previous_scope = default_scoping.last || unscoped
          default_scoping << previous_scope.merge(scope)
        end
        
        def scopes
          @_scopes ||= {}
        end
        
        def scopes=(scopes)
          @_scopes = scopes
        end
        
        def default_scoping
          @_default_scoping ||= []
        end
        
        def default_scoping=(scoping)
          @_default_scoping = scoping
        end
        
        def inherited(subclass)
          super
          subclass.scopes = scopes.dup
          subclass.default_scoping = default_scoping.dup
        end
      
      protected
        def with_scope(scope, &block)
          current_scopes << current_scope.merge(scope)
          
          begin
            yield
          ensure
            current_scopes.pop
          end
        end
        
      private
        def current_scope
          current_scopes.last || unscoped
        end
        
        def current_scopes
          Thread.current[:"#{self}_scopes"] ||= default_scoping.dup
        end
        
        def reset_current_scopes
          Thread.current[:"#{self}_scopes"] = nil
        end
      end
    end
  end
end
