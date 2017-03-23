module MongoModel
  class Scope
    module Batches
      def in_batches(batch_size=1000)
        offset = 0

        begin
          documents = offset(offset).limit(batch_size).all
          yield documents if block_given? && !documents.empty?
          offset += batch_size
        end until documents.size < batch_size
      end
    end
  end
end
