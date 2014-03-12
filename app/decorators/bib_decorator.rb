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
    bib_array = []
    bib_array << "\tauthor = \"#{bib_author_lists}\""
    bib_array << "\tname = \"#{name}\""
    bib_array << "\tjournal = \"#{journal}\""
    bib_array << "\tyear = \"#{year}\""
    bib_array << "\tnumber = \"#{number}\"" if number.present?
    bib_array << "\tmonth = \"#{month}\"" if month.present?
    bib_array << "\tvolume = \"#{volume}\"" if volume.present?
    bib_array << "\tpages = \"#{pages}\"" if pages.present?
    bib_array << "\tnote = \"#{note}\"" if note.present?
    bib_array << "\tdoi = \"#{doi}\"" if doi.present?
    bib_array << "\tkey = \"#{key}\"" if key.present?
    
    bib_array.join(",\n")
  end
  
  def misc_tex
    bib_array = []
    bib_array << "\tauthor = \"#{bib_author_lists}\""
    bib_array << "\tname = \"#{name}\""
    bib_array << "\tnumber = \"#{number}\"" if number.present?
    bib_array << "\tmonth = \"#{month}\"" if month.present?
    bib_array << "\tjournal = \"#{journal}\"" if journal.present?
    bib_array << "\tvolume = \"#{volume}\"" if volume.present?
    bib_array << "\tpages = \"#{pages}\"" if pages.present?
    bib_array << "\tyear = \"#{year}\"" if year.present?
    bib_array << "\tnote = \"#{note}\"" if note.present?
    bib_array << "\tdoi = \"#{doi}\"" if doi.present?
    bib_array << "\tkey = \"#{key}\"" if key.present?
    
    bib_array.join(",\n")
  end
  
  def bib_author_lists
    authors.pluck(:name).join(" ")
  end
  
end
