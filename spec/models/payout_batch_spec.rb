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
end
