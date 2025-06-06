# frozen_string_literal: true

module TransactionEngine
  module HashedTransactionService
    module RawStripeTransaction
      class Import
        include ::TransactionEngine::Shared

        def initialize(start_date: nil)
          @start_date = start_date || last_1_month
        end

        def run
          ::RawStripeTransaction.where("date_posted >= ?", @start_date).find_each(batch_size: 100) do |rst|
            begin
              ph = primary_hash(rst)

              ::HashedTransaction.find_or_initialize_by(raw_stripe_transaction_id: rst.id).tap do |ht|
                ht.primary_hash = ph[0]
                ht.primary_hash_input = ph[1]
              end.save!
            rescue ArgumentError => e
              puts "RawStripeTransaction #{rst.id}: #{e}"

              raise e
            end
          end
        end

        private

        def primary_hash(rst)
          ::TransactionEngine::HashedTransactionService::PrimaryHash.new(
            unique_bank_identifier: rst.unique_bank_identifier,
            date: rst.date_posted.strftime("%Y-%m-%d"),
            amount_cents: rst.amount_cents,
            memo: rst.memo.upcase
          ).run
        end

      end
    end
  end
end
