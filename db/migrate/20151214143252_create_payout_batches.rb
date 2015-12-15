class CreatePayoutBatches < ActiveRecord::Migration
  def change
    create_table :payout_batches do |t|
      t.string :status
      t.string :sender_batch_id
      t.string :email_subject
      t.float :amount, null: false, default: 0.0
      t.references :currency, index: true, foreign_key: true
      t.float :fees, null: false, default: 0.0

      t.timestamps null: false
    end
  end
end
