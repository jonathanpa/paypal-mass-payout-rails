class AddPaypalIdToPayoutBatches < ActiveRecord::Migration
  def change
    add_column :payout_batches, :paypal_id, :string
  end
end
