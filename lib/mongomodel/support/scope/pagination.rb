module MongoModel
  class Scope
    module Pagination
      def paginate(options={})
        page     = options[:page] || 1
        per_page = options[:per_page] || klass.per_page

        Paginator.new(self, page, per_page)
      end
    end
  end
end
