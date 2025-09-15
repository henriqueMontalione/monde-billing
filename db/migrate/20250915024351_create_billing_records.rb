class CreateBillingRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :billing_records do |t|
      t.references :customer, null: false, foreign_key: true
      t.integer :month, null: false
      t.integer :year, null: false
      t.datetime :processed_at, null: false
      t.integer :status, default: 0, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.text :error_message
      t.string :transaction_id
      
      t.timestamps
    end
    
    # Index para idempotência por período
    add_index :billing_records, [:customer_id, :month, :year], 
              unique: true, name: 'index_billing_records_on_customer_period'
    
    # Index para consultas por data/hora processamento
    add_index :billing_records, :processed_at
  end
end