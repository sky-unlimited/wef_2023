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

ActiveRecord::Schema[7.1].define(version: 2024_01_26_151207) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

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

  create_table "airports", force: :cascade do |t|
    t.string "icao", null: false
    t.string "name"
    t.string "city"
    t.bigint "country_id", null: false
    t.string "iata"
    t.float "latitude", null: false
    t.float "longitude", null: false
    t.integer "altitude"
    t.string "dst"
    t.string "airport_type", null: false
    t.string "url"
    t.string "local_code"
    t.geography "lonlat", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "actif", default: true
    t.index ["country_id"], name: "index_airports_on_country_id"
    t.index ["id"], name: "index_airports_on_id", unique: true
  end

  create_table "audit_logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "target_id", null: false
    t.integer "target_controller", null: false
    t.integer "action", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ip_address", default: "::1", null: false
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "username"
    t.string "last_name"
    t.string "first_name"
    t.string "company"
    t.string "email", null: false
    t.string "phone"
    t.integer "category", null: false
    t.text "description", null: false
    t.boolean "accept_privacy_policy"
    t.string "ip_address", null: false
    t.string "honey_bot"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "countries", force: :cascade do |t|
    t.string "code", null: false
    t.string "name"
    t.string "continent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_countries_on_id", unique: true
  end

  create_table "fuel_stations", force: :cascade do |t|
    t.bigint "airport_id", null: false
    t.integer "provider", null: false
    t.integer "status", null: false
    t.integer "fuel_avgas_100ll"
    t.integer "fuel_avgas_91ul"
    t.integer "fuel_mogas"
    t.integer "charging_station"
    t.string "email"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["airport_id"], name: "index_fuel_stations_on_airport_id"
  end

  create_table "osm_lines", force: :cascade do |t|
    t.bigint "osm_id", null: false
    t.string "osm_name"
    t.string "amenity", null: false
    t.string "tags"
    t.string "category"
    t.geometry "way", limit: {:srid=>3857, :type=>"line_string"}
    t.float "distance"
    t.integer "airport_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "osm_points", force: :cascade do |t|
    t.bigint "osm_id", null: false
    t.string "osm_name"
    t.string "amenity", null: false
    t.string "tags"
    t.string "category"
    t.geometry "way", limit: {:srid=>3857, :type=>"st_point"}
    t.float "distance"
    t.integer "airport_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "osm_polygones", force: :cascade do |t|
    t.bigint "osm_id", null: false
    t.string "osm_name"
    t.string "amenity", null: false
    t.string "tags"
    t.string "category"
    t.geometry "way", limit: {:srid=>3857, :type=>"st_polygon"}
    t.float "distance"
    t.integer "airport_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pilot_prefs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "weather_profile", default: 0, null: false
    t.integer "min_runway_length", default: 250, null: false
    t.boolean "fuel_card_total", default: false, null: false
    t.boolean "fuel_card_bp", default: false, null: false
    t.integer "max_gnd_wind_speed", default: 15, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_ultralight_pilot", default: false, null: false
    t.boolean "is_private_pilot", default: false, null: false
    t.bigint "airport_id"
    t.integer "average_true_airspeed", default: 100, null: false
    t.index ["airport_id"], name: "index_pilot_prefs_on_airport_id"
    t.index ["user_id"], name: "index_pilot_prefs_on_user_id"
  end

  create_table "runways", force: :cascade do |t|
    t.bigint "airport_id", null: false
    t.integer "internal_id", null: false
    t.integer "length_meter"
    t.integer "width_meter"
    t.string "surface"
    t.string "le_ident"
    t.string "he_ident"
    t.string "le_heading_degT"
    t.string "he_heading_degT"
    t.boolean "lighted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["airport_id"], name: "index_runways_on_airport_id"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "subscribers", force: :cascade do |t|
    t.string "email", null: false
    t.boolean "accept_private_data_policy"
    t.string "unsubscribe_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ip_address", default: "::1", null: false
    t.string "honey_bot"
  end

  create_table "trip_requests", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "airport_id", null: false
    t.datetime "start_date", null: false
    t.datetime "end_date"
    t.integer "trip_mode", null: false
    t.boolean "proxy_food", default: false, null: false
    t.boolean "proxy_fuel_car", default: false, null: false
    t.boolean "proxy_car_rental", default: false, null: false
    t.boolean "proxy_bike_rental", default: false, null: false
    t.boolean "proxy_camp_site", default: false, null: false
    t.boolean "proxy_accommodation", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "international_flight", default: false
    t.boolean "small_airport", default: false
    t.boolean "medium_airport", default: true
    t.boolean "large_airport", default: false
    t.boolean "proxy_shop", default: false
    t.boolean "proxy_bus_station", default: false
    t.boolean "proxy_train_station", default: false
    t.boolean "proxy_hiking_path", default: false
    t.boolean "proxy_coastline", default: false
    t.boolean "fuel_station_100ll", default: false
    t.boolean "proxy_beverage", default: false
    t.boolean "proxy_lake", default: false
    t.boolean "fuel_station_91ul", default: false
    t.boolean "fuel_station_mogas", default: false
    t.boolean "charging_station", default: false
    t.index ["airport_id"], name: "index_trip_requests_on_airport_id"
    t.index ["user_id"], name: "index_trip_requests_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sign_in_count"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts"
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "username", default: "user123", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "weather_calls", force: :cascade do |t|
    t.decimal "lon", precision: 4, scale: 2, null: false
    t.decimal "lat", precision: 4, scale: 2, null: false
    t.text "json"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "airports", "countries"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "fuel_stations", "airports"
  add_foreign_key "pilot_prefs", "airports"
  add_foreign_key "pilot_prefs", "users"
  add_foreign_key "runways", "airports"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "trip_requests", "airports"
  add_foreign_key "trip_requests", "users"
end
