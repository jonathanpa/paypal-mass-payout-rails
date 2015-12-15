# == Schema Information
#
# Table name: payout_batches
#
#  id              :integer          not null, primary key
#  status          :string
#  sender_batch_id :string
#  email_subject   :string
#  amount          :float            default(0.0), not null
#  currency_id     :integer
#  fees            :float            default(0.0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class PayoutBatch < ActiveRecord::Base
  before_validation :set_pending_status, on: :create
  before_validation :set_sender_batch_it, on: :create

  has_many :payout_items
  belongs_to :currency

  validates :status, presence: true
  validates :sender_batch_id, presence: true,
    uniqueness: { case_sensitive: false }

  validates :amount, presence: true,
    numericality: { greater_than_or_equal_to: 0 }

  validates :fees, presence: true,
    numericality: { greater_than_or_equal_to: 0 }

  validates :currency, presence: true

  private

  def set_pending_status
    self.status = 'UNSENT'
  end

  def set_sender_batch_it
    self.sender_batch_id = SecureRandom.hex(8)
  end
end
