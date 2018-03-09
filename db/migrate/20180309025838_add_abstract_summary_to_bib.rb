class AddAbstractSummaryToBib < ActiveRecord::Migration
  def change
    add_column :bibs, :abstract, :text
    add_column :bibs, :summary, :text
  end
end
