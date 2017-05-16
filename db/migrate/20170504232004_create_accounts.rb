class CreateAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :accounts do |t|
      t.string :account_id
      t.decimal :balance, precision: 8, scale: 2
    end
    add_index :accounts, :account_id
  end
end
