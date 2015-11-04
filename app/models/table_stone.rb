class TableStone < ActiveRecord::Base

  belongs_to :table
  belongs_to :stone

  before_create :assign_position, :create_table_analyses

  private

  def assign_position
    self.position = (self.class.where(table_id: table_id).maximum(:position) || 0) + 1
  end

  def create_table_analyses
    stone.analyses.each.with_index do |analysis, index|
      TableAnalysis.create!(table_id: table_id, stone_id: stone_id, analysis_id: analysis.id, priority: index)
    end
  end
end
