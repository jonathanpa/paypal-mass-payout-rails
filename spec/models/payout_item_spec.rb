describe PayoutItem do
  it { should validate_presence_of(:amount) }
  it { should validate_numericality_of(:amount).
         is_greater_than_or_equal_to(0) }

  it { should validate_presence_of(:fees) }
  it { should validate_numericality_of(:fees).
         is_greater_than_or_equal_to(0) }

  it { should validate_presence_of(:payout_batch) }
  it { should validate_presence_of(:currency) }
  it { should validate_presence_of(:payee) }

  describe 'after_build' do
    context 'on create' do
      let!(:item) { FactoryGirl.build(:payout_item) }

      it { expect { item.save! }.to change { item.transaction_status }.
           from(nil).to('UNSENT') }

      it { expect { item.save! }.to change { item.sender_item_id }.
           from(nil).to(a_string_matching(/[0-9a-f]{8}/)) }
    end

    context 'on save on existing item' do
      let!(:item) { FactoryGirl.create(:payout_item,
                                       transaction_status: 'SUCCESS') }

      it { expect { item.save! }.not_to change { item.transaction_status } }
      it { expect { item.save! }.not_to change { item.sender_item_id } }
    end
  end

  describe '#format_for_paypal' do
    let!(:item) { FactoryGirl.build(:payout_item) }

    it 'generates a hash formatted for Paypal API' do
      returned_hash = item.format_for_paypal

      expect(returned_hash[:recipient_type]).to eq 'EMAIL'
      expect(returned_hash[:amount][:value]).to eq item.amount
      expect(returned_hash[:amount][:currency]).to eq item.currency.to_s
      expect(returned_hash[:note]).to eq item.note
      expect(returned_hash[:receiver]).to eq item.payee.email
      expect(returned_hash[:sender_item_id]).to eq item.sender_item_id
    end
  end
end
