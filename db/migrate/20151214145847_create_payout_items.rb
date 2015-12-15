class CreatePayoutItems < ActiveRecord::Migration
  def change
    create_table :payout_items do |t|
      t.string :transaction_id
      t.string :transaction_status
      t.float :amount, null: false, default: 0.0
      t.float :fees, null: false, default: 0.0
      t.string :note
      t.string :sender_item_id
      t.date :time_processed
      t.references :payout_batch, index: true, foreign_key: true
      t.references :currency, index: true, foreign_key: true
      t.references :payee, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
