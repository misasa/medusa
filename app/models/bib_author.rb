class BibAuthor < ActiveRecord::Base
  belongs_to :bib
  belongs_to :author
  
  #TODO bibの新規作成時にexistenceバリデーションが掛かるため一旦コメントアウト
  #validates :bib, existence: true
  validates :author, existence: true
end
