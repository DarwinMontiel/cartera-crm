# Paginación simple por offset, sin dependencias externas.
class Pagination
  attr_reader :page, :per, :count, :pages, :records

  def initialize(scope, page:, per: 20)
    @per = per
    @count = scope.count
    @pages = [ (count / per.to_f).ceil, 1 ].max
    @page = page.to_i.clamp(1, pages)
    @records = scope.limit(per).offset((@page - 1) * per)
  end

  def next_page = page < pages ? page + 1 : nil
  def prev_page = page > 1 ? page - 1 : nil

  def meta
    { page:, per_page: per, total: count, pages: }
  end
end
