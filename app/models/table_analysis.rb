class TableAnalysis < ActiveRecord::Base

  belongs_to :table
  belongs_to :specimen
  belongs_to :analysis

end
