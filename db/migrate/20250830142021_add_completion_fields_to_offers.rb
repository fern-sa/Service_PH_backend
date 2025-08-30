class AddCompletionFieldsToOffers < ActiveRecord::Migration[7.2]
  def change
    add_column :offers, :completion_notes, :text
    add_column :offers, :completed_at, :datetime
  end
end
