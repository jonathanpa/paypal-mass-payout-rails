describe Payee do
  # let!(:sign_up_url) { 'http://payoneer.com/signup' }
  # let!(:sign_up_response) { Payoneer::Response.new('000', sign_up_url) }
  #
  # before do
  #   allow(Payoneer::Payee).to receive(:signup_url).
  #     and_return(sign_up_response)
  # end
  #
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email).case_insensitive }
  it { should validate_presence_of(:balance) }
  it { should validate_numericality_of(:balance).
         is_greater_than_or_equal_to(0) }
  it { should validate_presence_of(:currency) }
  #
  # describe 'validations' do
  #   before { allow_any_instance_of(Payee).to receive(:sign_up) }
  #
  #   it { should validate_presence_of(:email) }
  #   it { should validate_uniqueness_of(:email).case_insensitive }
  #   it { should validate_presence_of(:balance) }
  #   it { should validate_numericality_of(:balance).
  #        is_greater_than_or_equal_to(20.0) }
  #   it { should validate_presence_of(:currency) }
  # end
  #
  # describe '#payout' do
  #   let!(:payee) { FactoryGirl.create(:payee) }
  #   let!(:payment_id) { 'qwertyuiop' }
  #   let!(:payout_response) do
  #     Payoneer::Response.new('000', 'Processed Successfully')
  #   end
  #
  #   before do
  #     program_id = Rails.application.secrets.
  #       payoneer[payee.currency.code.downcase]['program_id']
  #     expect(SecureRandom).to receive(:hex).and_return(payment_id)
  #     expect(Payoneer::Payout).to receive(:create).
  #       with(hash_including(
  #         program_id: program_id,
  #         payment_id: payment_id,
  #         payee_id: payee.email,
  #         amount: payee.balance,
  #         currency: payee.currency.code)).
  #         and_return(payout_response)
  #   end
  #
  #   it { expect(payee.make_payout).to eq(payout_response) }
  #
  #   it 'creates a payout for payee' do
  #     expect(payee.payouts.count).to eq 0
  #     payee.make_payout
  #
  #     expect(payee.payouts.count).to eq 1
  #     payout = payee.payouts.first
  #     expect(payout.payment_id).to eq(payment_id)
  #     expect(payout.amount).to eq(payee.balance)
  #     expect(payout.response_code).to eq(payout_response.code)
  #     expect(payout.response_description).to eq(payout_response.body)
  #     expect(payout.currency).to eq(payee.currency)
  #   end
  # end
  #
  # describe '#sign_up' do
  #   let!(:payee) { FactoryGirl.build(:payee) }
  #   let!(:return_tag) { 'qwertyuiop' }
  #   let!(:redirect_url) { 'http://localhost' }
  #
  #   before do
  #     allow(SecureRandom).to receive(:hex).and_return(return_tag)
  #     expect(payee).to receive(:redirect_url).and_return(redirect_url)
  #     expect(Payoneer::Payee).to receive(:signup_url).
  #       with(payee.email, redirect_url: redirect_url).
  #       and_return(sign_up_response)
  #   end
  #
  #   it { expect { payee.save! }.to change { payee.sign_up_url }.to(sign_up_url) }
  #   it { expect { payee.save! }.to change { payee.return_tag }.to(return_tag) }
  # end
  #
  # describe '#redirect_url' do
  #   let!(:payee) { FactoryGirl.create(:payee) }
  #   let!(:expected_url) do
  #     "http://" + Rails.application.secrets.payoneer['redirect_host'] + ":" +
  #       Rails.application.secrets.payoneer['redirect_port'].to_s +
  #       "/payees/" + payee.id.to_s + "/confirm" + "?tag=" + payee.return_tag
  #   end
  #
  #   subject { payee.send(:redirect_url) }
  #
  #   it { should == expected_url }
  # end
  #
  # describe '#payoneer_for_currency' do
  #   let!(:payee) { FactoryGirl.create(:payee, currency: currency) }
  #
  #   context 'usd' do
  #     let!(:currency) { FactoryGirl.create(:usd) }
  #
  #     it 'configures Payoneer with correct credentials' do
  #       expected_partner_id =
  #         Rails.application.secrets.payoneer['usd']['partner_id']
  #
  #       payee.send(:payoneer_for_currency)
  #
  #       expect(Payoneer.configuration.partner_id).to eq expected_partner_id
  #     end
  #   end
  #
  #   context 'eur' do
  #     let!(:currency) { FactoryGirl.create(:eur) }
  #
  #     it 'configures Payoneer with correct credentials' do
  #       expected_partner_id =
  #         Rails.application.secrets.payoneer['eur']['partner_id']
  #
  #       payee.send(:payoneer_for_currency)
  #
  #       expect(Payoneer.configuration.partner_id).to eq expected_partner_id
  #     end
  #   end
  #
  #   context 'gbp' do
  #     let!(:currency) { FactoryGirl.create(:gbp) }
  #
  #     it 'configures Payoneer with correct credentials' do
  #       expected_partner_id =
  #         Rails.application.secrets.payoneer['gbp']['partner_id']
  #
  #       payee.send(:payoneer_for_currency)
  #
  #       expect(Payoneer.configuration.partner_id).to eq expected_partner_id
  #     end
  #   end
  # end
end
