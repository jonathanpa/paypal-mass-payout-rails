class CreateCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.string :code, null: false

      t.timestamps null: false
    end
  end
end
