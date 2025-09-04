class AddPaymentMethodToOffers < ActiveRecord::Migration[7.2]
  def change
    add_column :offers, :payment_method, :string, default: 'cash'
  end
end
