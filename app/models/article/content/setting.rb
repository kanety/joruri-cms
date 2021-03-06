# encoding: utf-8
class Article::Content::Setting < Cms::ContentSetting
  set_config :word_dictionary,
             name: "本文/単語変換辞書",
             form_type: :text, lower_text: "CSV形式（例　対象文字,変換後文字 ）"
  set_config :auto_link_check,
             name: "本文/自動リンクチェック",
             options: [%w(有効 enabled), %w(無効 disabled)]
  set_config :default_map_position,
             name: "地図/デフォルト座標",
             comment: "（経度, 緯度）"
  set_config :inquiry_default_state,
             name: "連絡先/表示初期値",
             options: [%w(表示 visible), %w(非表示 hidden)]
  set_config :inquiry_email_display,
             name: "連絡先/メールアドレス表示",
             options: [["表示（必須）", 'visible'], ["表示（任意）", 'visible_opt'], %w(非表示 hidden)]
  set_config :recognition_type,
             name: "承認/承認フロー",
             options: [%w(管理者承認が必要 with_admin)]
  set_config :recognizers_include_admin,
             name: "承認/他所属の管理者を表示",
             options: [%w(表示する visible), %w(表示しない hidden)]
  # set_config :default_recognizers, :name => "承認/デフォルト承認者"
  set_config :allowed_attachment_type,
             name: "添付ファイル/許可する種類",
             comment: "（例　<tt>gif,jpg,png,pdf,doc,xls,ppt,odt,ods,odp</tt> ）"
  set_config :attachment_resize_size,
             name: "添付ファイル/自動リサイズ",
             options: Sys::Model::Base::File.sizes,
             style: 'width: 100px;'
  set_config :attachment_thumbnail_size,
             name: "添付ファイル/サムネイルサイズ",
             comment: "（例　<tt>120x90</tt> ）",
             style: 'width: 100px;'
  set_config :new_term,
             name: "新着マーク表示期間",
             comment: "時間（1日=24時間）、0:非表示"

  validate :validate_value

  def validate_value
    case name
    when 'default_map_position'
      if !value.blank? && value !~ /^[0-9\.]+ *, *[0-9\.]+$/
        errors.add :value, :invalid
      end
    when 'new_term'
      if !value.blank? && value !~ /^([1-9]\d*|0)(\.\d+)?$/
        errors.add :value, :invalid
      end
    end
  end

  def config_options
    case name
    when 'default_recognizers'
      users = Sys::User.enabled.order(:account)
      return users.collect { |c| [c.name_with_account, c.id.to_s] }
    end
    super
  end

  def value_name
    unless value.blank?
      case name
      when 'default_recognizers'
        user = Sys::User.find_by(id: value)
        return user.name_with_account if user
      end
    end
    super
  end
end
