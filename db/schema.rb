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

ActiveRecord::Schema[8.1].define(version: 2026_03_04_013726) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "badges", force: :cascade do |t|
    t.string "badge_type"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "icon"
    t.string "name"
    t.integer "threshold"
    t.datetime "updated_at", null: false
  end

  create_table "books", force: :cascade do |t|
    t.string "author"
    t.string "cover_image"
    t.datetime "created_at", null: false
    t.string "isbn"
    t.string "status"
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_books_on_user_id"
  end

  create_table "finds", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.datetime "created_at", null: false
    t.datetime "found_at"
    t.bigint "label_id", null: false
    t.string "photo"
    t.integer "points_awarded"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["book_id"], name: "index_finds_on_book_id"
    t.index ["label_id"], name: "index_finds_on_label_id"
    t.index ["user_id"], name: "index_finds_on_user_id"
  end

  create_table "friendships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "friend_id"
    t.string "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_friendships_on_user_id"
  end

  create_table "labels", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.datetime "created_at", null: false
    t.bigint "location_id", null: false
    t.string "qr_code"
    t.string "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["book_id"], name: "index_labels_on_book_id"
    t.index ["location_id"], name: "index_labels_on_location_id"
    t.index ["user_id"], name: "index_labels_on_user_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.string "location_type"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "user_badges", force: :cascade do |t|
    t.datetime "awarded_at"
    t.bigint "badge_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["badge_id"], name: "index_user_badges_on_badge_id"
    t.index ["user_id"], name: "index_user_badges_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar"
    t.text "bio"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "points"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "books", "users"
  add_foreign_key "finds", "books"
  add_foreign_key "finds", "labels"
  add_foreign_key "finds", "users"
  add_foreign_key "friendships", "users"
  add_foreign_key "labels", "books"
  add_foreign_key "labels", "locations"
  add_foreign_key "labels", "users"
  add_foreign_key "user_badges", "badges"
  add_foreign_key "user_badges", "users"
end
