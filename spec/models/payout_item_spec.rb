describe PayoutItem do
  it { should validate_presence_of(:amount) }
  it { should validate_numericality_of(:amount).
         is_greater_than_or_equal_to(0) }

  it { should validate_presence_of(:fees) }
  it { should validate_numericality_of(:fees).
         is_greater_than_or_equal_to(0) }

  it { should validate_presence_of(:sender_item_id) }
  it { should validate_presence_of(:payout_batch) }
  it { should validate_presence_of(:currency) }
  it { should validate_presence_of(:payee) }
end
