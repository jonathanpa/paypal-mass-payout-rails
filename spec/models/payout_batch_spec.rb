describe PayoutBatch do
  it { should validate_presence_of(:amount) }
  it { should validate_numericality_of(:amount).
         is_greater_than_or_equal_to(0) }

  it { should validate_presence_of(:fees) }
  it { should validate_numericality_of(:fees).
         is_greater_than_or_equal_to(0) }

  it { should validate_presence_of(:currency) }
  
  describe 'after_build' do
    context 'on create' do
      let!(:batch) { FactoryGirl.build(:payout_batch) }

      it { expect { batch.save! }.to change { batch.status }.from(nil).
           to('UNSENT') }

      it { expect { batch.save! }.to change { batch.sender_batch_id }.from(nil).
           to(a_string_matching(/[0-9a-f]{8}/)) }
    end

    context 'on save on existing batch' do
      let!(:batch) { FactoryGirl.create(:payout_batch, status: 'PROCESSED') }

      it { expect { batch.save! }.not_to change { batch.status } }
      it { expect { batch.save! }.not_to change { batch.sender_batch_id } }
    end
  end

  describe '#format_for_paypal' do
    let!(:batch) { FactoryGirl.create(:payout_batch_with_items) }

    it 'generates a hash formatted for Paypal API' do
      returned_hash = batch.format_for_paypal

      expect(returned_hash[:sender_batch_header][:sender_batch_id]).
        to eq batch.sender_batch_id

      expect(returned_hash[:sender_batch_header][:email_subject]).
        to eq batch.email_subject

      expect(returned_hash[:items].size).to eq batch.payout_items.count

      receivers_emails = returned_hash[:items].map { |item| item[:receiver] }
      expect(receivers_emails).to eq batch.payees.pluck(:email)
    end
  end

  describe '#post' do
    context 'status UNSENT' do
      let!(:batch) { FactoryGirl.create(:payout_batch_with_items) }

      it 'sends a payout POST request to Paypal' do
        expected_batch_hash = batch.format_for_paypal
        payout = double(PayPal::SDK::REST::Payment)

        expect(PayPal::SDK::REST::Payout).to receive(:new).
          with(expected_batch_hash).
          and_return(payout)

        expect(payout).to receive(:create)

        batch.post
      end
    end

    context 'status != UNSENT' do
      let!(:batch) { FactoryGirl.create(:payout_batch_with_items,
                                        status: 'SUCCESS') }

      it { expect { batch.post }.
             to raise_error(Paypal::MassPayout::BatchSentException,
                            /already sent/) }
    end
  end
end
