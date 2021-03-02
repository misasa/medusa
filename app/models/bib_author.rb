# -*- coding: utf-8 -*-
class BibAuthor < ApplicationRecord
  belongs_to :bib, touch: true
  belongs_to :author
  
  #TODO bibの新規作成時にexistenceバリデーションが掛かるため一旦コメントアウト
  #validates :bib, existence: true
  validates :author, presence: true

end
