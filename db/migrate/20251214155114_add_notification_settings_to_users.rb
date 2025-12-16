# frozen_string_literal: true

class AddNotificationSettingsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :notify_on_new_photo, :boolean, default: true, null: false
    add_column :users, :notify_on_comment, :boolean, default: true, null: false
    add_column :users, :notify_on_reaction, :boolean, default: true, null: false
  end
end
