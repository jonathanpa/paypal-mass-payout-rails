class CreatePayees < ActiveRecord::Migration
  def change
    create_table :payees do |t|
      t.string :email
      t.float :balance
      t.references :currency, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
