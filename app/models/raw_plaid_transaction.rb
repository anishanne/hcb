# frozen_string_literal: true

# == Schema Information
#
# Table name: raw_plaid_transactions
#
#  id                     :bigint           not null, primary key
#  amount_cents           :integer
#  date_posted            :date
#  pending                :boolean          default(FALSE)
#  plaid_transaction      :jsonb
#  unique_bank_identifier :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  plaid_account_id       :text
#  plaid_item_id          :text
#  plaid_transaction_id   :text
#
class RawPlaidTransaction < ApplicationRecord
  has_many :hashed_transactions
  has_one :canonical_transaction, as: :transaction_source
  belongs_to :bank_account, primary_key: :plaid_account_id, foreign_key: :plaid_account_id, inverse_of: :raw_plaid_transactions, optional: true

  delegate :name, to: :bank_account, prefix: true, allow_nil: true

  monetize :amount_cents

  def memo
    @memo ||= plaid_transaction["name"]
  end

end
