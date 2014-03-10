# -*- coding: utf-8 -*-
class BibDecorator < Draper::Decorator
  delegate_all

  def name_with_id
    h.content_tag(:span, nil, class: "glyphicon glyphicon-cloud") + " #{name} < #{global_id} >"
  end
  
  def to_tex
    if entry_type == "article"
      tex = "\n@article{#{abbreviation.presence || global_id},\n#{article_tex},\n}"
    else
      tex = "\n@misc{#{abbreviation.presence || global_id},\n#{misc_tex},\n}"
    end
    return tex
  end
  
  def article_tex
    bib = object
    bib_array = []
    authors_name = bib_author_lists
    bib_array << "\tauthor = \"#{authors_name}\""
    bib_array << "\tname = \"#{bib.name}\""
    bib_array << "\tjournal = \"#{bib.journal}\""
    bib_array << "\tyear = \"#{bib.year}\""
    bib_array << "\tnumber = \"#{bib.number}\"" if bib.number.present?
    bib_array << "\tmonth = \"#{bib.month}\"" if bib.month.present?
    bib_array << "\tvolume = \"#{bib.volume}\"" if bib.volume.present?
    bib_array << "\tpages = \"#{bib.pages}\"" if bib.pages.present?
    bib_array << "\tnote = \"#{bib.note}\"" if bib.note.present?
    bib_array << "\tdoi = \"#{bib.doi}\"" if bib.doi.present?
    bib_array << "\tkey = \"#{bib.key}\"" if bib.key.present?
    
    bib_array.join(",\n")
  end
  
  def misc_tex
    bib = object
    bib_array = []
    authors_name = bib_author_lists
    bib_array << "\tauthor = \"#{authors_name}\""
    bib_array << "\tname = \"#{bib.name}\""
    bib_array << "\tnumber = \"#{bib.number}\"" if bib.number.present?
    bib_array << "\tmonth = \"#{bib["month"]}\"" if bib.month.present?
    bib_array << "\tjournal = \"#{bib["journal"]}\"" if bib.journal.present?
    bib_array << "\tvolume = \"#{bib["volume"]}\"" if bib.volume.present?
    bib_array << "\tpages = \"#{bib["pages"]}\"" if bib.pages.present?
    bib_array << "\tyear = \"#{bib["year"]}\"" if bib.year.present?
    bib_array << "\tnote = \"#{bib["note"]}\"" if bib.note.present?
    bib_array << "\tdoi = \"#{bib["doi"]}\"" if bib.doi.present?
    bib_array << "\tkey = \"#{bib["key"]}\"" if bib.key.present?
    
    bib_array.join(",\n")
  end
  
  def bib_author_lists
    authors.pluck(:name).join(" ")
  end
  
end
