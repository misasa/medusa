class TableSpecimen < ActiveRecord::Base

  belongs_to :table
  belongs_to :specimen

  before_create :assign_position, :create_table_analyses

  private

  def assign_position
    self.position = (self.class.where(table_id: table_id).maximum(:position) || 0) + 1
  end

  def create_table_analyses
    specimen.full_analyses.each.with_index do |analysis, index|
      TableAnalysis.create!(table_id: table_id, specimen_id: specimen_id, analysis_id: analysis.id, priority: index)
    end
  end
end
