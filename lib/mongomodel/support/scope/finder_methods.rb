module MongoModel
  class Scope
    module FinderMethods
      def find(*ids, &block)
        if block_given?
          to_a.find(&block)
        else
          ids.flatten!

          case ids.size
          when 0
            raise ArgumentError, "At least one id must be specified"
          when 1
            id = ids.first.to_s
            where(:id => id).first || raise(DocumentNotFound, "Couldn't find document with id: #{id}")
          else
            docs = where(:id.in => ids.map { |id| id.to_s }).to_a
            raise DocumentNotFound if docs.size != ids.size
            docs.sort_by { |doc| ids.index(doc.id) }
          end
        end
      end
      
      def first
        if loaded?
          @documents.first
        else
          @first ||= limit(1).to_a[0]
        end
      end
      
      def last
        if loaded?
          @documents.last
        else
          @last ||= reverse_order.limit(1).to_a[0]
        end
      end
      
      def all
        to_a
      end
      
      def exists?(id)
        where(:id => id).any?
      end
    end
  end
end
