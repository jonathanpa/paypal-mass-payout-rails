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
#  paypal_id       :string
#

class PayoutBatch < ActiveRecord::Base
  before_validation :set_unsent_status, on: :create
  before_validation :set_sender_batch_it, on: :create

  has_many :payout_items, dependent: :destroy
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
    begin
      pp_payout_batch = PayPal::SDK::REST::Payout.get(self.paypal_id)
      update_from_paypal(pp_payout_batch)
    rescue PayPal::SDK::Core::Exceptions::ResourceNotFound
      self.errors.add(:base, 'PayoutBatch not found')
      false
    end
  end

  def post
    if self.status == 'UNSENT'
      paypal_payout = PayPal::SDK::REST::Payout.new(format_for_paypal)
      pp_payout_batch = paypal_payout.create

      if pp_payout_batch.error
        self.errors.add(:base, pp_payout_batch.error['details'].first['issue'])
        false
      else
        update_from_paypal(pp_payout_batch)
      end
    end
  end

  def format_for_paypal
    { sender_batch_header: {
        sender_batch_id: self.sender_batch_id,
        email_subject: self.email_subject },
      items: self.payout_items.map(&:format_for_paypal) }
  end

  def update_from_paypal(pp_payout_batch)
    self.paypal_id = pp_payout_batch.batch_header.payout_batch_id
    self.status = pp_payout_batch.batch_header.batch_status
    self.amount = pp_payout_batch.batch_header.amount.value.to_f
    self.fees = pp_payout_batch.batch_header.fees.value.to_f
    save!

    update_items_from_paypal(pp_payout_batch)
  end

  def sent?
    self.status != 'UNSENT'
  end

  def unsent?
    self.status == 'UNSENT'
  end

  private

  def set_unsent_status
    self.status = 'UNSENT' if self.status.blank?
  end

  def set_sender_batch_it
    self.sender_batch_id = SecureRandom.hex(8) if self.sender_batch_id.blank?
  end

  def update_items_from_paypal(pp_payout_batch)
    pp_payout_batch.items.each do |item_details|
      payout_item = self.payout_items.
        find_by(sender_item_id: item_details.payout_item.sender_item_id)

      payout_item.update_from_paypal(item_details)
    end
  end
end
