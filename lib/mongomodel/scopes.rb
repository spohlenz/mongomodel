require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/object/metaclass'

module MongoModel
  module Scopes
    extend ActiveSupport::Concern
    
    included do
      class << self
        [:find, :count].each do |method|
          alias_method_chain method, :scope
        end
      end
      
      named_scope :scoped, lambda { |scope| scope }
    end
    
    module ClassMethods
    protected
      #
      def named_scope(name, options={})
        named_scopes[name] = options
        
        metaclass.instance_eval do
          define_method(name) do |*args|
            scope(name).apply(*args)
          end
        end
      end
    
      #
      def default_scope(options={})
        if options.empty?
          read_inheritable_attribute(:default_scope) || write_inheritable_attribute(:default_scope, Scope.new(self))
        else
          write_inheritable_attribute(:default_scope, default_scope.merge(:find => options))
        end
      end
      
      #
      def with_scope(options={}, &block)
        push_scope(current_scope.merge(options), &block)
      end
      
      #
      def with_exclusive_scope(options={}, &block)
        push_scope(Scope.new(self, options), &block)
      end
    
    private
      def push_scope(scope, &block)
        scopes << scope
        yield
      ensure
        scopes.pop
      end
    
      def find_with_scope(*args)
        options = args.extract_options!
        options = current_scope.options_for(:find).deep_merge(options)
        
        find_without_scope(*(args << options))
      end
      
      def count_with_scope(conditions={})
        scope_conditions = current_scope.options_for(:find)[:conditions] || {}
        
        count_without_scope(scope_conditions.deep_merge(conditions))
      end
      
      def named_scopes
        read_inheritable_attribute(:named_scopes) || write_inheritable_attribute(:named_scopes, {})
      end
      
      def scope(name)
        Scope.new(self, named_scopes[name]) if named_scopes[name]
      end
      
      def scopes
        Thread.current[:"#{self}_scopes"] ||= [ default_scope.dup ]
      end
    
      def current_scope
        scopes.last
      end
    end
  end
  
  class Scope
    attr_reader :model, :options
    
    delegate :with_scope, :with_exclusive_scope, :scope, :to => :model
    delegate :inspect, :to => :proxy_found
    
    def initialize(model, options={})
      if options.is_a?(Proc) || options.has_key?(:find) || options.has_key?(:create)
        @options = options
      else
        @exclusive = options.delete(:exclusive)
        @options = { :find => options }
      end
      
      @model = model
    end
    
    def merge(scope)
      raise ArgumentError, "Scope must be applied before it can be merged" unless options.is_a?(Hash)
      options_to_merge = scope.is_a?(self.class) ? scope.options : scope
      self.class.new(model, options.deep_merge(options_to_merge))
    end
    
    def merge!(scope)
      raise ArgumentError, "Scope must be applied before it can be merged" unless options.is_a?(Hash)
      options_to_merge = scope.is_a?(self.class) ? scope.options : scope
      options.deep_merge!(options_to_merge)
      self
    end
    
    def reload
      @found = nil
      self
    end
    
    def apply(*args)
      if options.is_a?(Hash)
        reload
      else
        self.class.new(model, options.call(*args))
      end
    end
    
    def options_for(action=:find)
      options[action] || {}
    end
    
    def exclusive?
      @exclusive == true
    end
    
  protected
    def proxy_found
      @found ||= find(:all)
    end
    
  private
    def method_missing(method, *args, &block)
      if scope = scope(method)
        scope.exclusive? ? scope : merge(scope.apply(*args))
      else
        send(scope_type, options) { model.send(method, *args, &block) }
      end
    end
    
    def scope_type
      exclusive? ? :with_exclusive_scope : :with_scope
    end
  end
end
