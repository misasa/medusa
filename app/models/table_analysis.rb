class TableAnalysis < ActiveRecord::Base

  belongs_to :table
  belongs_to :stone
  belongs_to :analysis

end
