module MongoModel
  module DocumentParent
    extend ActiveSupport::Concern

    def parent_document
      if @_parent_document.is_a?(Proc)
        case @_parent_document.arity
        when 0 then @_parent_document.call
        else        @_parent_document.call(self)
        end
      else
        @_parent_document
      end
    end

    def parent_document=(doc)
      @_parent_document = doc
    end
  end
end
