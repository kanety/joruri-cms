# encoding: utf-8
module Article::Model::Rel::Doc::Area
  extend ActiveSupport::Concern

  included do
    scope :area_is, ->(area) {
      return all if area.blank?

      area = [area] unless area.class == Array
      ids  = []

      searcher = lambda do |_area|
        _area.each do |_c|
          next if _c.level_no > 4
          next if ids.index(_c.id)
          ids << _c.id
          searcher.call(_c.public_children)
        end
      end

      searcher.call(area)
      ids = ids.uniq

      if ids.empty?
        all
      else
        where(
          arel_table[:area_ids].in(ids)
          .or(arel_table[:area_ids].matches("#{ids.join('|')} %"))
          .or(arel_table[:area_ids].matches("% #{ids.join('|')} %"))
          .or(arel_table[:area_ids].matches("% #{ids.join('|')}"))
        )
      end
    }
  end

  def in_area_ids
    val = @in_area_ids
    @in_area_ids = area_ids.to_s.split(' ').uniq unless val
    @in_area_ids
  end

  def in_area_ids=(ids)
    _ids = []
    if ids.class == Array
      ids.each { |val| _ids << val }
      self.area_ids = _ids.join(' ')
    elsif ids.class == Hash || ids.class == HashWithIndifferentAccess  \
          || ids.class == ActionController::Parameters
      ids.each { |key, val| _ids << key unless val.blank? }
      self.area_ids = _ids.join(' ')
    else
      self.area_ids = ids
    end
  end

  def area_items(options = {})
    ids = area_ids.to_s.split(' ').uniq
    return [] if ids.empty?

    items = Article::Area.where(id: ids)
    items = items.where(state: options[:state]) if options[:state]
    items
  end
end
