class CreateOffers < ActiveRecord::Migration[7.2]
  def change
    create_table :offers do |t|
      t.references :task,               null: false, foreign_key: true
      t.references :service_provider,   null: false, foreign_key: { to_table: :users }
      t.decimal :price,                 precision: 10, scale: 2, null: false
      t.text :message,                  null: false
      t.string :status,                 default: 'pending'
      t.datetime :availability_date,    null: false
      t.text :terms
      t.datetime :accepted_at
      t.datetime :rejected_at

      t.timestamps
    end

    add_index :offers, [:task_id, :service_provider_id], unique: true
    add_index :offers, :status
    add_index :offers, :availability_date
  end
end
