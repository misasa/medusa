module RecordsHelper

  def contain_searchable_symbol(attribute)
    "#{records_search_matcher(attribute)}_cont".to_sym
  end

  def gteq_searchable_symbol(attribute)
    "#{records_search_matcher(attribute)}_gteq".to_sym
  end

  def lteq_searchable_symbol(attribute)
    "#{records_search_matcher(attribute)}_lteq_end_of_day".to_sym
  end

end
