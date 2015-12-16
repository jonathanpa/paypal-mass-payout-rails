module PaypalDatatypeDoubleHelper
  def double_payout_batch(values)
    values[:batch_header] = double_payout_batch_header(values[:batch_header])

    values[:items] = values[:items].map do |item|
      double_payout_item_details(item)
    end

    instance_double(PayPal::SDK::REST::DataTypes::PayoutBatch, values)
  end

  def double_payout_batch_header(values)
    values[:amount] = double_currency(values[:amount])
    values[:fees] = double_currency(values[:fees])
    instance_double(PayPal::SDK::REST::DataTypes::PayoutBatchHeader, values)
  end

  def double_currency(values)
    instance_double(PayPal::SDK::REST::DataTypes::Currency, values)
  end

  def double_payout_item_details(values)
    values[:payout_item] = double_payout_item(values[:payout_item])
    values[:payout_item_fee] = double_currency(values[:payout_item_fee])
    instance_double(PayPal::SDK::REST::DataTypes::PayoutItemDetails, values)
  end

  def double_payout_item(values)
    values[:amount] = double_currency(values[:amount])
    instance_double(PayPal::SDK::REST::DataTypes::PayoutItem, values)
  end

  def batch_values(batch_status: 'SUCCESS',
                   total_amount: 10.0,
                   total_fees: 0.2,
                   currency: 'EUR',
                   payout_batch_id: SecureRandom.hex(8),
                   items: [])

    batch = {
      batch_header: {
        batch_status: batch_status,
        amount: { value: total_amount.to_s, currency: currency },
        fees: { value: total_fees.to_s, currency: currency },
        payout_batch_id: payout_batch_id,
      },
      items: items
    }

    if items.empty?
      batch[:items] = item_values
    else
      batch[:items].map! { |i| item_values(i) }
    end

    batch
  end

  def item_values(amount: '10.0',
                 fee: '0.2',
                 currency: 'EUR',
                 sender_item_id: SecureRandom.hex(8),
                 payout_item_id: SecureRandom.hex(8),
                 time_processed: Time.now.to_formatted_s(:iso8601),
                 transaction_id: SecureRandom.hex(8),
                 transaction_status: 'SUCCESS')
    {
      payout_item: {
        amount: { value: amount, currency: currency },
        sender_item_id: sender_item_id,
      },
      payout_item_fee: { value: fee, currency: currency },
      payout_item_id: payout_item_id,
      time_processed: time_processed,
      transaction_id: transaction_id,
      transaction_status: transaction_status
    }
  end
end

RSpec.configure do |c|
  c.include PaypalDatatypeDoubleHelper
end
