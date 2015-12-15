# == Schema Information
#
# Table name: payees
#
#  id          :integer          not null, primary key
#  email       :string
#  balance     :float
#  currency_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Payee < ActiveRecord::Base
  # has_many :payouts
  belongs_to :currency

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :balance, presence: true,
    numericality: { greater_than_or_equal_to: 0 }

  validates :currency, presence: true

  # after_create :sign_up
  #
  # def make_payout
  #   description = "Test payout to #{self.email} with amount #{self.balance}"
  #
  #   payout = self.payouts.build(payment_id: SecureRandom.hex(8),
  #                               amount: self.balance,
  #                               description: description,
  #                               currency: self.currency)
  #
  #   response = payoneer_for_currency::Payout.create(
  #     program_id: Rails.application.secrets.payoneer['usd']['program_id'],
  #     payment_id: payout.payment_id,
  #     payee_id: self.email,
  #     amount: self.balance,
  #     description: description,
  #     payment_date: Time.now,
  #     currency: self.currency.code)
  #
  #   payout.response_code = response.code
  #   payout.response_description = response.body
  #   payout.save!
  #   response
  # end
  #
  # private
  #
  # def sign_up
  #   self.return_tag = SecureRandom.hex(8)
  #   response = payoneer_for_currency::Payee.signup_url(self.email,
  #                                                    redirect_url: redirect_url)
  #   self.sign_up_url = response.body if response.ok?
  #   save!
  # end
  #
  # def redirect_url
  #   uri = URI::HTTP.build(host: Rails.application.secrets.payoneer['redirect_host'],
  #                        port: Rails.application.secrets.payoneer['redirect_port'],
  #                        path: "/payees/#{self.id}/confirm",
  #                        query: "tag=#{self.return_tag}")
  #   uri.to_s
  # end
  #
  # def payoneer_for_currency
  #   PayoneerManager.send(self.currency.code.downcase)
  # end
end
