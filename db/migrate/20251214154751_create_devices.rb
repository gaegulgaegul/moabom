class CreateDevices < ActiveRecord::Migration[8.1]
  def change
    create_table :devices do |t|
      t.references :user, null: false, foreign_key: true
      t.string :platform, null: false
      t.string :push_token
      t.string :device_id, null: false
      t.string :app_version
      t.string :os_version
      t.datetime :last_active_at

      t.timestamps
    end

    add_index :devices, [ :user_id, :device_id ], unique: true
    add_index :devices, :push_token
  end
end
