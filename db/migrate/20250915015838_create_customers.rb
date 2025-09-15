class CreateCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :customers do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.integer :billing_day, null: false
      t.string :payment_method_type, null: false
      
      t.timestamps
    end
    
    add_index :customers, :email, unique: true
  end
end