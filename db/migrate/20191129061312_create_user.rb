class CreateUser < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :uid, null: false, index: { unique: true }
      t.string :slack_name
      t.timestamps
    end
  end
end
