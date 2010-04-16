module MongoModel
  module DocumentExtensions
    module Scopes
      extend ActiveSupport::Concern
      
      module ClassMethods
        delegate :find, :first, :last, :all, :exists?, :count, :to => :scoped
        delegate :select, :order, :where, :limit, :offset, :from, :to => :scoped
        
        def unscoped
          @unscoped ||= MongoModel::Scope.new(self)
        end
        
        def scoped
          unscoped.clone
        end
        
        def scopes
          read_inheritable_attribute(:scopes) || write_inheritable_attribute(:scopes, {})
        end
        
        def scope(name, scope)
          name = name.to_sym
          
          scopes[name] = scope
          
          singleton_class.class_eval do
            define_method(name) do
              scopes[name]
            end
          end
        end
        
      #   def current_scope
      #     current_scopes.last
      #   end
      # 
      # private
      #   def current_scopes
      #     key = :"#{self}_scopes"
      #     Thread.current[key] = Thread.current[key].presence || self.default_scoping.dup
      #   end
      end
    end
  end
end
