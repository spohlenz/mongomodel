module MongoModel
  class Scope
    module LoadMethods
      attr_accessor :on_load_proc
      
      def on_load(&block)
        new_scope = clone
        new_scope.on_load_proc = block
        new_scope
      end
    end
  end
end
