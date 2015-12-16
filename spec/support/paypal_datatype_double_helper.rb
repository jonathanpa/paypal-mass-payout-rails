module PaypalDatatypeDoubleHelper
  def double_payout_batch(values)
    values[:batch_header] = double_payout_batch_header(values[:batch_header])
    instance_double(PayPal::SDK::REST::DataTypes::PayoutBatch, values)
  end

  def double_payout_batch_header(values)
    values[:amount] = double_currency(values[:amount]) if values[:amount]
    values[:fees] = double_currency(values[:fees]) if values[:fees]
    instance_double(PayPal::SDK::REST::DataTypes::PayoutBatchHeader, values)
  end

  def double_currency(values)
    instance_double(PayPal::SDK::REST::DataTypes::Currency, values)
  end
end

RSpec.configure do |c|
  c.include PaypalDatatypeDoubleHelper
end
