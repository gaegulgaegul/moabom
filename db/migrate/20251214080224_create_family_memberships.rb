class CreateFamilyMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :family_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :family, null: false, foreign_key: true
      t.integer :role, null: false, default: 0

      t.timestamps
    end

    add_index :family_memberships, [ :user_id, :family_id ], unique: true
  end
end
