class AddPaypalIdToPayoutItems < ActiveRecord::Migration
  def change
    add_column :payout_items, :paypal_id, :string
  end
end
