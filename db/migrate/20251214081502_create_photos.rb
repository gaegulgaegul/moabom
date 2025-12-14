# frozen_string_literal: true

class CreatePhotos < ActiveRecord::Migration[8.1]
  def change
    create_table :photos do |t|
      t.references :family, null: false, foreign_key: true
      t.references :uploader, null: false, foreign_key: { to_table: :users }
      t.references :child, foreign_key: true
      t.text :caption
      t.datetime :taken_at, null: false

      t.timestamps
    end

    add_index :photos, %i[family_id taken_at]
  end
end
