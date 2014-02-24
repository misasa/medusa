module RecordsHelper

  def contain_searchable_symbol(attribute)
    "#{ransackable_matcher(attribute)}_cont".to_sym
  end

  def gteq_searchable_symbol(attribute)
    "#{ransackable_matcher(attribute)}_gteq".to_sym
  end

  def lteq_searchable_symbol(attribute)
    "#{ransackable_matcher(attribute)}_lteq_end_of_day".to_sym
  end

  private

  def ransackable_matcher(attribute)
    str = "datum_of_Stone_type_#{attribute}_or_"
    str += "datum_of_Box_type_#{attribute}_or_"
    str += "datum_of_Place_type_#{attribute}_or_"
    str += "datum_of_Analysis_type_#{attribute}_or_"
    str += "datum_of_Bib_type_#{attribute}_or_"
    str += "datum_of_AttachmentFile_type_#{attribute}"
    str
  end

end
