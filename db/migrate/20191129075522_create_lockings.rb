class CreateLockings < ActiveRecord::Migration[5.2]
  def change
    create_table :lockings do |t|
      t.references :user, foreign_key: true, null: false
      t.string :floor, null: false

      t.timestamps
    end
  end
end
