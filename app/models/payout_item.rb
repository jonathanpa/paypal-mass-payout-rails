# == Schema Information
#
# Table name: payout_items
#
#  id                 :integer          not null, primary key
#  transaction_id     :string
#  transaction_status :string
#  amount             :float            default(0.0), not null
#  fees               :float            default(0.0), not null
#  note               :string
#  sender_item_id     :string
#  time_processed     :date
#  payout_batch_id    :integer
#  currency_id        :integer
#  payee_id           :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class PayoutItem < ActiveRecord::Base
  belongs_to :payout_batch
  belongs_to :currency
  belongs_to :payee

  validates :amount, presence: true,
    numericality: { greater_than_or_equal_to: 0 }

  validates :fees, presence: true,
    numericality: { greater_than_or_equal_to: 0 }

  validates :sender_item_id, presence: true
  validates :payout_batch, presence: true
  validates :currency, presence: true
  validates :payee, presence: true
end
