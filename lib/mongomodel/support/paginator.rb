module MongoModel
  class Paginator < Array
    attr_reader :current_page, :per_page, :total_entries

    def initialize(scope, page, per_page)
      @current_page = page.to_i
      @per_page = per_page.to_i

      super(scope.offset(offset).limit(per_page))

      # Try to autodetect total entries
      if total_entries.nil? && size < per_page && (current_page == 1 or size > 0)
        @total_entries = offset + size
      else
        @total_entries = scope.count
      end
    end

    def total_pages
      total_entries.zero? ? 1 : (total_entries / per_page.to_f).ceil
    end

    def previous_page
      current_page > 1 ? (current_page - 1) : nil
    end

    def next_page
      current_page < total_pages ? (current_page + 1) : nil
    end

    def out_of_bounds?
      current_page > total_pages
    end

    def offset
      (current_page - 1) * per_page
    end
  end
end
