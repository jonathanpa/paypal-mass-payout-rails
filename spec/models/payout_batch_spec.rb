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
      let(:batch) { FactoryGirl.build(:payout_batch) }

      it { expect { batch.save! }.to change { batch.status }.from(nil).
           to('UNSENT') }

      it { expect { batch.save! }.to change { batch.sender_batch_id }.from(nil).
           to(a_string_matching(/[0-9a-f]{8}/)) }
    end

    context 'on save on existing batch' do
      let(:batch) { FactoryGirl.create(:payout_batch, status: 'PROCESSED') }

      it { expect { batch.save! }.not_to change { batch.status } }
      it { expect { batch.save! }.not_to change { batch.sender_batch_id } }
    end
  end

  describe '#format_for_paypal' do
    let(:batch) { FactoryGirl.create(:payout_batch_with_items) }

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
    let(:pp_payout_status) { 'SUCCESS' }
    let(:pp_payout_batch_id) { 'BA3JVV5G4SCZN' }

    let(:pp_items) do
      batch.payout_items.map { |i| { sender_item_id: i.sender_item_id } }
    end

    let(:pp_payout_batch) do
      batch_double(batch_status: pp_payout_status,
                   payout_batch_id: pp_payout_batch_id,
                   items: pp_items)
    end

    describe '#fetch' do
      let(:batch) { FactoryGirl.create(:payout_batch_with_items, :pending) }

      let!(:payout_get_mock) do
        expect(PayPal::SDK::REST::Payout).to receive(:get).
          with(batch.paypal_id).
          and_return(pp_payout_batch)
      end

      it { expect(batch.fetch).to be_truthy }

      it { expect { batch.fetch }.to change { batch.reload.status }.
           from('PENDING').
           to('SUCCESS') }

      it { expect { batch.fetch }.to change { batch.reload.amount }.
           from(0.0).
           to(10.0) }

      it { expect { batch.fetch }.to change { batch.reload.fees }.
           from(0.0).
           to(0.2) }

      it 'updates the items' do
        pp_payout_batch.items.each do |item|
          payout_item = batch.payout_items.
            find_by(sender_item_id: item.payout_item.sender_item_id)

          expect(payout_item.paypal_id).to eq nil
          expect(payout_item.transaction_id).to eq nil
          expect(payout_item.transaction_status).to eq 'UNSENT'
          expect(payout_item.fees).to eq 0.0
        end

        batch.fetch
        batch.reload

        pp_payout_batch.items.each do |item|
          payout_item = batch.payout_items.
            find_by(sender_item_id: item.payout_item.sender_item_id)

          expect(payout_item.paypal_id).to eq item.payout_item_id
          expect(payout_item.transaction_id).to eq item.transaction_id
          expect(payout_item.transaction_status).to eq 'SUCCESS'
          expect(payout_item.fees).to eq 0.2
        end
      end

      context 'not found' do
        let!(:pp_not_found_exception) do
          PayPal::SDK::Core::Exceptions::
            ResourceNotFound.new('Failed.  Response code = 404.')
        end

        let!(:payout_get_mock) do
          expect(PayPal::SDK::REST::Payout).to receive(:get).
            with(batch.paypal_id).
            and_raise(pp_not_found_exception)
        end

        it { expect(batch.fetch).to be_falsy }
        it { expect { batch.fetch }.not_to change { batch.reload.status } }
        it { expect { batch.fetch }.
             to change { batch.reload.errors.count }.by(1) }
      end
    end

    describe '#post' do
      context 'status UNSENT' do
        let(:batch) { FactoryGirl.create(:payout_batch_with_items) }

        let(:pp_payout) { instance_double(PayPal::SDK::REST::Payout) }

        let(:pp_payout_status) { 'PENDING' }

        let(:expected_batch_hash) { batch.format_for_paypal }

        let!(:payout_new_mock) do
          expect(PayPal::SDK::REST::Payout).to receive(:new).
            with(expected_batch_hash).
            and_return(pp_payout)
        end

        let!(:payout_create_mock) do
          expect(pp_payout).to receive(:create).
            and_return(pp_payout_batch)
        end

        it { expect(batch.post).to be_truthy }

        it { expect { batch.post }.to change { batch.reload.status }.
             to(pp_payout_status) }

        it { expect { batch.post }.to change { batch.reload.paypal_id }.
             to(pp_payout_batch_id) }

        context 'Paypal batch error' do
          let(:pp_payout_batch) do
            batch_double(batch_status: pp_payout_status,
                         payout_batch_id: pp_payout_batch_id,
                         items: pp_items,
                         error: { details: [{ issue: 'The issue' }] })
          end

          it { expect(batch.post).to be_falsy }
          it { expect { batch.post }.not_to change { batch.reload.status } }
        end
      end

      context 'status != UNSENT' do
        let(:batch) { FactoryGirl.create(:payout_batch_with_items, :pending) }

        it { expect(batch.post).to be_falsy }

        it 'does not send a payout create order to Paypal' do
          expect_any_instance_of(PayPal::SDK::REST::Payout).not_to receive(:create)
          batch.post
        end

        it { expect { batch.post }.not_to change { batch.reload.status } }
      end
    end
  end
end
