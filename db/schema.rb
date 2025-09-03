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

ActiveRecord::Schema[7.2].define(version: 2025_09_02_104222) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "icon", default: "🔧"
    t.integer "sort_order", default: 0
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_categories_on_active"
    t.index ["sort_order"], name: "index_categories_on_sort_order"
  end

  create_table "offers", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.bigint "service_provider_id", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.text "message", null: false
    t.string "status", default: "pending"
    t.datetime "availability_date", null: false
    t.text "terms"
    t.datetime "accepted_at"
    t.datetime "rejected_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "completion_notes"
    t.datetime "completed_at"
    t.string "payment_method", default: "cash"
    t.index ["availability_date"], name: "index_offers_on_availability_date"
    t.index ["service_provider_id"], name: "index_offers_on_service_provider_id"
    t.index ["status"], name: "index_offers_on_status"
    t.index ["task_id", "service_provider_id"], name: "index_offers_on_task_id_and_service_provider_id", unique: true
    t.index ["task_id"], name: "index_offers_on_task_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.bigint "offer_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "payment_method", default: "cash"
    t.string "status", default: "pending"
    t.string "stripe_payment_intent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["offer_id"], name: "index_payments_on_offer_id"
    t.index ["task_id"], name: "index_payments_on_task_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "category_id", null: false
    t.string "title", null: false
    t.text "description", null: false
    t.decimal "budget_min", precision: 10, scale: 2
    t.decimal "budget_max", precision: 10, scale: 2
    t.string "location", null: false
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "city"
    t.string "province"
    t.datetime "preferred_date"
    t.string "status", default: "open"
    t.integer "assigned_offer_id"
    t.datetime "completed_at"
    t.decimal "final_price", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_tasks_on_category_id"
    t.index ["created_at"], name: "index_tasks_on_created_at"
    t.index ["latitude", "longitude"], name: "index_tasks_on_latitude_and_longitude"
    t.index ["preferred_date"], name: "index_tasks_on_preferred_date"
    t.index ["status"], name: "index_tasks_on_status"
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "jti", null: false
    t.string "location"
    t.decimal "longitude"
    t.decimal "latitude"
    t.integer "age"
    t.string "phone"
    t.integer "total_reviews", default: 0
    t.decimal "rating"
    t.text "bio"
    t.string "city"
    t.string "province"
    t.integer "service_radius_km", default: 20
    t.boolean "verified", default: false
    t.boolean "active", default: true
    t.string "user_type", default: "customer"
    t.index ["active"], name: "index_users_on_active"
    t.index ["city", "province"], name: "index_users_on_city_and_province"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["phone"], name: "index_users_on_phone", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["user_type"], name: "index_users_on_user_type"
    t.index ["verified"], name: "index_users_on_verified"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "offers", "tasks"
  add_foreign_key "offers", "users", column: "service_provider_id"
  add_foreign_key "payments", "offers"
  add_foreign_key "payments", "tasks"
  add_foreign_key "tasks", "categories"
  add_foreign_key "tasks", "users"
end
