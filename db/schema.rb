# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_12_21_133942) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "children", force: :cascade do |t|
    t.date "birthdate", null: false
    t.datetime "created_at", null: false
    t.integer "family_id", null: false
    t.integer "gender"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_children_on_family_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.integer "photo_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["photo_id"], name: "index_comments_on_photo_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "devices", force: :cascade do |t|
    t.string "app_version"
    t.datetime "created_at", null: false
    t.string "device_id", null: false
    t.datetime "last_active_at"
    t.string "os_version"
    t.string "platform", null: false
    t.string "push_token"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["push_token"], name: "index_devices_on_push_token"
    t.index ["user_id", "device_id"], name: "index_devices_on_user_id_and_device_id", unique: true
    t.index ["user_id"], name: "index_devices_on_user_id"
  end

  create_table "families", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "onboarding_completed_at"
    t.datetime "updated_at", null: false
    t.index ["onboarding_completed_at"], name: "index_families_on_onboarding_completed_at"
  end

  create_table "family_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "family_id", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["family_id"], name: "index_family_memberships_on_family_id"
    t.index ["user_id", "family_id"], name: "index_family_memberships_on_user_id_and_family_id", unique: true
    t.index ["user_id"], name: "index_family_memberships_on_user_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.integer "family_id", null: false
    t.integer "inviter_id", null: false
    t.integer "role", default: 1, null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_invitations_on_family_id"
    t.index ["inviter_id"], name: "index_invitations_on_inviter_id"
    t.index ["token"], name: "index_invitations_on_token", unique: true
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "actor_id", null: false
    t.datetime "created_at", null: false
    t.integer "notifiable_id", null: false
    t.string "notifiable_type", null: false
    t.string "notification_type", null: false
    t.datetime "read_at"
    t.integer "recipient_id", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_notifications_on_actor_id"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["recipient_id", "created_at"], name: "index_notifications_on_recipient_id_and_created_at"
    t.index ["recipient_id", "read_at"], name: "index_notifications_on_recipient_id_and_read_at"
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
  end

  create_table "photos", force: :cascade do |t|
    t.text "caption"
    t.integer "child_id"
    t.datetime "created_at", null: false
    t.integer "family_id", null: false
    t.datetime "taken_at", null: false
    t.datetime "updated_at", null: false
    t.integer "uploader_id", null: false
    t.index ["child_id"], name: "index_photos_on_child_id"
    t.index ["family_id", "taken_at"], name: "index_photos_on_family_id_and_taken_at"
    t.index ["family_id"], name: "index_photos_on_family_id"
    t.index ["uploader_id"], name: "index_photos_on_uploader_id"
  end

  create_table "reactions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "emoji", null: false
    t.integer "photo_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["photo_id"], name: "index_reactions_on_photo_id"
    t.index ["user_id", "photo_id"], name: "index_reactions_on_user_id_and_photo_id", unique: true
    t.index ["user_id"], name: "index_reactions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "nickname", null: false
    t.boolean "notify_on_comment", default: true, null: false
    t.boolean "notify_on_new_photo", default: true, null: false
    t.boolean "notify_on_reaction", default: true, null: false
    t.datetime "onboarding_completed_at"
    t.string "provider", null: false
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "children", "families"
  add_foreign_key "comments", "photos"
  add_foreign_key "comments", "users"
  add_foreign_key "devices", "users"
  add_foreign_key "family_memberships", "families"
  add_foreign_key "family_memberships", "users"
  add_foreign_key "invitations", "families"
  add_foreign_key "invitations", "users", column: "inviter_id"
  add_foreign_key "notifications", "users", column: "actor_id"
  add_foreign_key "notifications", "users", column: "recipient_id"
  add_foreign_key "photos", "children"
  add_foreign_key "photos", "families"
  add_foreign_key "photos", "users", column: "uploader_id"
  add_foreign_key "reactions", "photos"
  add_foreign_key "reactions", "users"
end
