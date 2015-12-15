module Paypal
  module MassPayout
    class BatchSentException < StandardError
      def initialize(batch)
        @batch = batch
        super(build_message)
      end

      private

      def build_message
        "PayoutBatch [#{@batch.id}] with status #{@batch.status} already sent."
      end
    end
  end
end
