class AddAbstractSummaryToBib < ActiveRecord::Migration[4.2]
  def change
    add_column :bibs, :abstract, :text
    add_column :bibs, :summary, :text
  end
end
