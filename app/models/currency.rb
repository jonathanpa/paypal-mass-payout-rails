class Currency < ActiveRecord::Base
  validates :code, presence: true, uniqueness: { case_sensitive: false }
end
