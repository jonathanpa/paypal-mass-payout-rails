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
#  time_processed     :datetime
#  payout_batch_id    :integer
#  currency_id        :integer
#  payee_id           :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  paypal_id          :string
#

class PayoutItem < ActiveRecord::Base
  before_validation :set_transaction_status, on: :create
  before_validation :set_sender_item_id, on: :create

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


  def format_for_paypal
    { recipient_type: 'EMAIL',
      amount: {
        value: self.amount.round(2),
        currency: self.currency.to_s },
      note: self.note,
      receiver: self.payee.email,
      sender_item_id: self.sender_item_id }
  end

  def update_from_paypal(pp_item_detail)
    if self.sender_item_id == pp_item_detail.payout_item.sender_item_id
      self.paypal_id = pp_item_detail.payout_item_id
      self.transaction_id = pp_item_detail.transaction_id
      self.transaction_status = pp_item_detail.transaction_status
      self.fees = pp_item_detail.payout_item_fee.value.to_f

      if pp_item_detail.time_processed
        self.time_processed = Time.parse(pp_item_detail.time_processed)
      end

      save!
    else
      raise StandardError.new("Calling update_from_paypal for item[#{self.id}] 
                              with incoherent sender_item_id 
                              [#{pp_item_detail.payout_item.sender_item_id}]")
    end
  end

  private

  def set_transaction_status
    self.transaction_status = 'UNSENT'
  end

  def set_sender_item_id
    self.sender_item_id = SecureRandom.hex(8) 
  end
end
