# frozen_string_literal: true

class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      # 수신자 (알림을 받는 사용자)
      t.references :recipient, null: false, foreign_key: { to_table: :users }

      # 행위자 (알림을 발생시킨 사용자)
      t.references :actor, null: false, foreign_key: { to_table: :users }

      # 알림 대상 (Polymorphic)
      t.references :notifiable, polymorphic: true, null: false

      # 알림 타입
      t.string :notification_type, null: false

      # 읽음 여부
      t.datetime :read_at

      t.timestamps
    end

    # 인덱스
    add_index :notifications, [ :recipient_id, :read_at ]
    add_index :notifications, [ :recipient_id, :created_at ]
  end
end
