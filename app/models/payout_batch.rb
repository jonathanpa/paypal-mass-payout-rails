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
  has_many :payees, through: :payout_items
  belongs_to :currency

  validates :status, presence: true
  validates :sender_batch_id, presence: true,
    uniqueness: { case_sensitive: false }

  validates :amount, presence: true,
    numericality: { greater_than_or_equal_to: 0 }

  validates :fees, presence: true,
    numericality: { greater_than_or_equal_to: 0 }

  validates :currency, presence: true

  def fetch
  end

  def post
    if self.status == 'UNSENT'
      paypal_payout = PayPal::SDK::REST::Payout.new(self.format_for_paypal)
      paypal_payout.create
    else
      raise Paypal::MassPayout::BatchSentException.new(self)
    end
  end

  def format_for_paypal
    { sender_batch_header: {
        sender_batch_id: self.sender_batch_id,
        email_subject: self.email_subject },
      items: self.payout_items.map(&:format_for_paypal) }
  end

  private

  def set_pending_status
    self.status = 'UNSENT' if self.status.blank?
  end

  def set_sender_batch_it
    self.sender_batch_id = SecureRandom.hex(8)
  end
end
