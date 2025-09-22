class AddRetryFieldsToBillingRecords < ActiveRecord::Migration[7.1]
  def change
    add_column :billing_records, :retry_count, :integer, default: 0, null: false
    add_column :billing_records, :error_details, :text
  end
end
