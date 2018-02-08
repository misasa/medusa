module SystemPreferencesHelper

  IGNORE_KEYS = %w(initial_password password)

  def settings_list(settings)
    content_tag(:ul, settings.inject("") { |html, pair| raw(html + settings_item(*pair)) })
  end

  private

  def settings_item(key, value)
    return "" if IGNORE_KEYS.include?(key)
    content_tag(:li) { raw "#{content_tag(:strong, key)}: #{parse_settings_value(value)}" }
  end

  def parse_settings_value(value)
    case value
    when Array
      value.map { |v| settings_list(v) }.join
    when Hash
      settings_list(value)
    else
      value
    end
  end
end
