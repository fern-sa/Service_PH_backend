class CreatePayments < ActiveRecord::Migration[7.2]
  def change
    create_table :payments do |t|
      t.references :task, null: false, foreign_key: true
      t.references :offer, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :payment_method, default: 'cash'
      t.string :status, default: 'pending'
      t.string :stripe_payment_intent_id

      t.timestamps
    end
  end
end
