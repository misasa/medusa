class TableAnalysis < ApplicationRecord

  belongs_to :table, touch: true
  belongs_to :specimen
  belongs_to :analysis

end
