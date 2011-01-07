require 'will_paginate/collection'

module MongoModel
  class Scope
    module Pagination
      def paginate(options={})
        page     = options[:page] || 1
        per_page = options[:per_page] || klass.per_page
        
        WillPaginate::Collection.create(page, per_page) do |pager|
          pager.replace offset(pager.offset).limit(pager.per_page)
          pager.total_entries ||= count
        end
      end
    end
  end
end
