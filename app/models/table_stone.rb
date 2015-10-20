class TableStone < ActiveRecord::Base

  belongs_to :table
  belongs_to :stone

  before_save :assign_position

  private

  def assign_position
    self.position = (self.class.where(table_id: table_id).maximum(:position) || 0) + 1
  end
end
