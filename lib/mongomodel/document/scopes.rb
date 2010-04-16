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
