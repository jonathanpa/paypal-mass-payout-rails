# == Schema Information
#
# Table name: currencies
#
#  id         :integer          not null, primary key
#  code       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Currency < ActiveRecord::Base
  has_many :payess
  has_many :payout_batches

  validates :code, presence: true, uniqueness: { case_sensitive: false }
end
