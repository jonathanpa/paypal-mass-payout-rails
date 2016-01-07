module PaypalDatatypeDouble
  def batch_double(batch_status: 'SUCCESS',
                   total_amount: 10.0,
                   total_fees: 0.2,
                   currency: 'EUR',
                   payout_batch_id: SecureRandom.hex(8),
                   error: nil,
                   items: [])

    batch = {
      batch_header: {
        batch_status: batch_status,
        amount: { value: total_amount.to_s, currency: currency },
        fees: { value: total_fees.to_s, currency: currency },
        payout_batch_id: payout_batch_id,
      },
      error: error,
      items: items
    }

    batch[:items].map! { |i| item_values(i) }

    Hashie::Mash.new(batch)
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
  c.include PaypalDatatypeDouble
end
