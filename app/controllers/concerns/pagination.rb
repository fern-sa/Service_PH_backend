module Pagination
  extend ActiveSupport::Concern

  private

  def paginate_collection(collection, per_page = 20)
    collection.page(params[:page]).per(per_page)
  end

  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      per_page: collection.limit_value,
      total_pages: collection.total_pages,
      total_count: collection.total_count
    }
  end
end