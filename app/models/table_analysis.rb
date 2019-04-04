class TableAnalysis < ActiveRecord::Base

  belongs_to :table, touch: true
  belongs_to :specimen
  belongs_to :analysis

end
