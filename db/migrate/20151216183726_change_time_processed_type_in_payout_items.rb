class ChangeTimeProcessedTypeInPayoutItems < ActiveRecord::Migration
  def change
    change_column :payout_items, :time_processed, :datetime
  end
end
