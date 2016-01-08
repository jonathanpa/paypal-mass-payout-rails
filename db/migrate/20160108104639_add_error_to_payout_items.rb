class AddErrorToPayoutItems < ActiveRecord::Migration
  def change
    add_column :payout_items, :error, :string
  end
end
