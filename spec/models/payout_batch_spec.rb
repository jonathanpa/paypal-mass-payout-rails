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

  describe '#fetch and #post' do
    let!(:pp_payout_status) { 'SUCCESS' }

    let!(:pp_payout_values) do
      {
        batch_header: {
          batch_status: pp_payout_status,
          amount: { value: '10.0', currency: 'EUR' },
          fees: { value: '0.2', currency: 'EUR' },
          payout_batch_id: 'BA3JVV5G4SCZN'
        }
      }
    end

    describe '#fetch' do
      let!(:batch) { FactoryGirl.create(:payout_batch_with_items,
                                        :pending,
                                        items_count: 1) }

      it 'sends a payout view order to Paypal' do
        allow(batch).to receive(:update_from_paypal)
        expect(PayPal::SDK::REST::Payout).to receive(:get).
          with(batch.paypal_id)

        batch.fetch
      end

      it 'updates the instance' do
        pp_payout = double_payout_batch(pp_payout_values)

        expect(PayPal::SDK::REST::Payout).to receive(:get).
          with(batch.paypal_id).
          and_return(pp_payout)

        expect(batch.status).to eq 'PENDING'
        expect(batch.amount).to eq 0.0
        expect(batch.fees).to eq 0.0

        batch.fetch
        batch.reload

        expect(batch.status).to eq 'SUCCESS'
        expect(batch.amount).to eq 10.0
        expect(batch.fees).to eq 0.2
      end
    end

    describe '#post' do
      context 'status UNSENT' do
        let!(:pp_payout_status) { 'PENDING' }
        let!(:batch) { FactoryGirl.create(:payout_batch_with_items) }
        let!(:pp_payout) { double(PayPal::SDK::REST::Payment) }

        it 'sends a payout create order to Paypal' do
          allow(batch).to receive(:update_from_paypal)

          expected_batch_hash = batch.format_for_paypal

          expect(PayPal::SDK::REST::Payout).to receive(:new).
            with(expected_batch_hash).
            and_return(pp_payout)

          expect(pp_payout).to receive(:create)

          batch.post
        end

        it 'updates the instance' do
          pp_payout_batch = double_payout_batch(pp_payout_values)

          expect(PayPal::SDK::REST::Payout).to receive(:new).and_return(pp_payout)
          expect(pp_payout).to receive(:create).
            and_return(pp_payout_batch)

          batch.post
          batch.reload

          expect(batch.status).to eq 'PENDING'
          expect(batch.paypal_id).to eq 'BA3JVV5G4SCZN'
        end
      end

      context 'status != UNSENT' do
        let!(:batch) { FactoryGirl.create(:payout_batch_with_items, :pending) }

        it { expect { batch.post }.
             to raise_error(Paypal::MassPayout::BatchSentException,
                            /already sent/) }
      end
    end
  end
end
