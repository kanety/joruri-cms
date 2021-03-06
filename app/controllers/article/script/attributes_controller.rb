# encoding: utf-8
class Article::Script::AttributesController < Cms::Controller::Script::Publication
  def publish
    units = Article::Unit.find_departments(web_state: 'public')
    if (unit_id = params[:target_child_id]).present?
      units = units.where(id: unit_id) 
    end

    if (target_id = params[:target_id]).present?
      attrs = Article::Attribute.where(id: target_id).all
    else
      cond = { state: 'public', content_id: @node.content_id }
      attrs = Article::Attribute.root_items(cond)
    end
    attrs.each do |item|
      uri  = "#{@node.public_uri}#{item.name}/"
      path = "#{@node.public_path}#{item.name}/"
      publish_page(item, uri: uri, path: path)
      publish_more(item, uri: uri, path: path, file: 'more', dependent: :more)
      publish_page(item, uri: "#{uri}index.rss", path: "#{path}index.rss", dependent: :rss)
      publish_page(item, uri: "#{uri}index.atom", path: "#{path}index.atom", dependent: :atom)

      units.each do |unit|
        uri  = "#{@node.public_uri}#{item.name}/#{unit.name}/"
        path = "#{@node.public_path}#{item.name}/#{unit.name}/"
        publish_more(item, rel_unid: unit.unid, uri: uri, path: path, dependent: "/#{unit.name}")
      end
    end

    render text: (@errors.empty? ? 'OK' : @errors.join("\n"))
  end
end
