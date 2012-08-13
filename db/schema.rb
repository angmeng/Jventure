# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110427180546) do

  create_table "agents", :force => true do |t|
    t.string   "code",                   :limit => 45
    t.string   "fullname",               :limit => 100
    t.string   "new_ic_number",          :limit => 12
    t.text     "resident_address"
    t.string   "residence_postcode",     :limit => 5
    t.string   "residence_city",         :limit => 45
    t.string   "residence_state",        :limit => 45
    t.string   "residence_phone_number", :limit => 12
    t.string   "mobile_number",          :limit => 45
    t.string   "email",                  :limit => 45
    t.integer  "upline_id",                             :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "licenses_count",                        :default => 0
    t.integer  "proposals_count",                       :default => 0
    t.date     "join_date",                             :default => '2010-02-11'
    t.string   "account_number",         :limit => 20
    t.string   "account_bank",           :limit => 45
    t.string   "password_hash"
    t.string   "password_salt"
    t.boolean  "master_agent",                          :default => false,        :null => false
    t.integer  "credits",                               :default => 0,            :null => false
    t.integer  "policy_count",                          :default => 0,            :null => false
    t.date     "birthday",                                                        :null => false
  end

  add_index "agents", ["credits"], :name => "index_agents_on_credits"
  add_index "agents", ["master_agent"], :name => "index_agents_on_master_agent"
  add_index "agents", ["upline_id"], :name => "index_agents_on_upline_id"

  create_table "approvals", :force => true do |t|
    t.date     "approval_date"
    t.text     "description"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "board_notices", :force => true do |t|
    t.string   "title",      :limit => 45
    t.text     "content"
    t.boolean  "suspend",                  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public"
  end

  create_table "commission_days", :force => true do |t|
    t.string   "description",           :limit => 45
    t.integer  "from_calculate_day",                  :default => 1
    t.integer  "to_calculate_day",                    :default => 31
    t.boolean  "basic_commission",                    :default => true
    t.boolean  "overriding_commission",               :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "renewal",                             :default => false
  end

  add_index "commission_days", ["renewal"], :name => "index_commission_days_on_renewal"

  create_table "commission_generations", :force => true do |t|
    t.date     "generate_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "commission_day_id"
  end

  add_index "commission_generations", ["commission_day_id"], :name => "index_commission_generations_on_commission_day_id"

  create_table "commission_reports", :force => true do |t|
    t.integer  "agent_id"
    t.integer  "user_id"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code",             :limit => 45
    t.string   "bank_account",     :limit => 45
    t.decimal  "basic_commission",               :precision => 10, :scale => 2
    t.decimal  "sub_commission",                 :precision => 10, :scale => 2
    t.decimal  "misc_amount",                    :precision => 10, :scale => 2
  end

  add_index "commission_reports", ["agent_id"], :name => "index_commission_reports_on_agent_id"
  add_index "commission_reports", ["user_id"], :name => "index_commission_reports_on_user_id"

  create_table "commission_transactions", :force => true do |t|
    t.integer  "proposal_id",                                         :default => 0
    t.integer  "agent_id",                                            :default => 0
    t.integer  "level_paid",                                          :default => 999
    t.decimal  "amount",               :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "case_cost",            :precision => 12, :scale => 2, :default => 0.0
    t.date     "date_paid"
    t.integer  "proposal_year",                                       :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "supplementary",                                       :default => false
    t.decimal  "percentage",           :precision => 10, :scale => 2, :default => 0.0,   :null => false
    t.boolean  "is_renew",                                            :default => false, :null => false
    t.integer  "proposal_approval_id",                                :default => 0,     :null => false
  end

  add_index "commission_transactions", ["supplementary"], :name => "index_commission_transactions_on_supplementary"

  create_table "commissions", :force => true do |t|
    t.integer  "commission_year",                                :default => 0
    t.integer  "plan_id",                                        :default => 0,   :null => false
    t.integer  "tier_id",                                                         :null => false
    t.decimal  "percentage",      :precision => 10, :scale => 2, :default => 0.0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "commissions", ["commission_year"], :name => "index_commissions_on_commission_year"

  create_table "contacts", :force => true do |t|
    t.string   "name",       :limit => 45
    t.text     "address"
    t.string   "telephone",  :limit => 20
    t.string   "fax",        :limit => 20
    t.string   "email",      :limit => 45
    t.text     "comment"
    t.boolean  "read",                     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "credit_points", :force => true do |t|
    t.integer  "agent_id"
    t.integer  "current_credit", :default => 0
    t.integer  "added_credit",   :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "expiring_proposals", :force => true do |t|
    t.integer  "proposal_id",                                        :null => false
    t.integer  "agent_id",                                           :null => false
    t.integer  "plan_id",                                            :null => false
    t.integer  "rookie_upline_id",                    :default => 0
    t.integer  "senior_recruiter_upline_id",          :default => 0
    t.integer  "assistant_chief_recruiter_upline_id", :default => 0
    t.integer  "chief_recruiter_upline_id",           :default => 0
    t.date     "expiry_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "expiring_proposals", ["agent_id"], :name => "index_expiring_proposals_on_agent_id"
  add_index "expiring_proposals", ["assistant_chief_recruiter_upline_id"], :name => "index_expiring_proposals_on_assistant_chief_recruiter_upline_id"
  add_index "expiring_proposals", ["chief_recruiter_upline_id"], :name => "index_expiring_proposals_on_chief_recruiter_upline_id"
  add_index "expiring_proposals", ["plan_id"], :name => "index_expiring_proposals_on_plan_id"
  add_index "expiring_proposals", ["proposal_id"], :name => "index_expiring_proposals_on_proposal_id"
  add_index "expiring_proposals", ["rookie_upline_id"], :name => "index_expiring_proposals_on_rookie_upline_id"
  add_index "expiring_proposals", ["senior_recruiter_upline_id"], :name => "index_expiring_proposals_on_senior_recruiter_upline_id"

  create_table "expiring_reports", :force => true do |t|
    t.integer  "report_month", :null => false
    t.integer  "report_year",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "expiring_reports", ["report_month"], :name => "index_expiring_reports_on_report_month"
  add_index "expiring_reports", ["report_year"], :name => "index_expiring_reports_on_report_year"

  create_table "login_records", :force => true do |t|
    t.integer  "agent_id"
    t.string   "ip_address",       :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "item_category_id"
  end

  add_index "login_records", ["agent_id"], :name => "index_login_records_on_agent_id"

  create_table "miscellaneous_items", :force => true do |t|
    t.date     "transaction_date"
    t.string   "title",              :limit => 45
    t.text     "description"
    t.decimal  "amount",                           :precision => 12, :scale => 2
    t.integer  "agent_id",                                                        :default => 0
    t.integer  "payment_fee_id",                                                  :default => 0,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "builtin",                                                         :default => false
    t.boolean  "overriding_charger",                                              :default => false
    t.integer  "charger_year",                                                    :default => 0
  end

  add_index "miscellaneous_items", ["builtin"], :name => "index_miscellaneous_items_on_builtin"
  add_index "miscellaneous_items", ["charger_year"], :name => "index_miscellaneous_items_on_charger_year"
  add_index "miscellaneous_items", ["overriding_charger"], :name => "index_miscellaneous_items_on_overriding_charger"

  create_table "mode_of_payments", :force => true do |t|
    t.string   "name",         :limit => 45
    t.text     "description"
    t.integer  "factor_month",               :default => 12, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nationalities", :force => true do |t|
    t.string   "name",        :limit => 45
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_fees", :force => true do |t|
    t.string   "name",           :limit => 45
    t.text     "description"
    t.decimal  "amount",                       :precision => 10, :scale => 2, :default => 0.0
    t.boolean  "is_enabled",                                                  :default => true, :null => false
    t.string   "related_column", :limit => 45,                                                  :null => false
    t.string   "related_value",  :limit => 45,                                                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_methods", :force => true do |t|
    t.string   "name",        :limit => 45
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plans", :force => true do |t|
    t.string   "name",          :limit => 45
    t.decimal  "sum_assured",                 :precision => 12, :scale => 2, :default => 0.0
    t.integer  "policy_term",                                                :default => 0
    t.integer  "premium_term",                                               :default => 0
    t.decimal  "modal_premium",               :precision => 12, :scale => 2, :default => 0.0
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "proposal_approvals", :force => true do |t|
    t.integer  "proposal_id"
    t.integer  "approval_year"
    t.boolean  "approved",      :default => false
    t.date     "approved_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "plan_id",       :default => 0
    t.date     "expired_date"
  end

  add_index "proposal_approvals", ["approval_year"], :name => "index_proposal_approvals_on_approval_year"
  add_index "proposal_approvals", ["approved"], :name => "index_proposal_approvals_on_approved"
  add_index "proposal_approvals", ["approved_date"], :name => "index_proposal_approvals_on_approved_date"
  add_index "proposal_approvals", ["plan_id"], :name => "index_proposal_approvals_on_plan_id"
  add_index "proposal_approvals", ["proposal_id"], :name => "index_proposal_approvals_on_proposal_id"

  create_table "proposals", :force => true do |t|
    t.string   "proposal_number",                 :limit => 45
    t.string   "policy_number",                   :limit => 45
    t.integer  "agent_id",                                                                      :default => 0
    t.integer  "investor_id",                                                                   :default => 0
    t.string   "code",                            :limit => 45
    t.string   "fullname",                        :limit => 100
    t.string   "new_ic_number",                   :limit => 12
    t.string   "old_ic_number",                   :limit => 12
    t.string   "birth_certificate",               :limit => 20
    t.string   "passport",                        :limit => 20
    t.date     "date_of_birth"
    t.integer  "age",                                                                           :default => 18
    t.text     "resident_address"
    t.string   "residence_postcode",              :limit => 5
    t.string   "residence_city",                  :limit => 45
    t.string   "residence_state",                 :limit => 45
    t.string   "residence_phone_number",          :limit => 12
    t.string   "mobile_number",                   :limit => 45
    t.string   "email",                           :limit => 45
    t.boolean  "has_proposer",                                                                  :default => false
    t.boolean  "proposer_is_agent",                                                             :default => false
    t.string   "proposer_fullname",               :limit => 100
    t.string   "proposer_new_ic_number",          :limit => 12
    t.string   "proposer_old_ic_number",          :limit => 12
    t.string   "proposer_birth_certificate",      :limit => 20
    t.string   "proposer_passport",               :limit => 20
    t.date     "proposer_date_of_birth"
    t.integer  "proposer_age",                                                                  :default => 18
    t.text     "proposer_resident_address"
    t.string   "proposer_residence_postcode",     :limit => 12
    t.string   "proposer_residence_city",         :limit => 45
    t.string   "proposer_residence_state",        :limit => 45
    t.string   "proposer_residence_phone_number", :limit => 12
    t.string   "proposer_mobile_number",          :limit => 12
    t.string   "proposer_relationship",           :limit => 45
    t.string   "proposer_email",                  :limit => 45
    t.integer  "mode_of_payment_id",                                                            :default => 0
    t.integer  "payment_method_id",                                                             :default => 0
    t.string   "plan_selection",                  :limit => 45
    t.decimal  "sum_assured",                                    :precision => 12, :scale => 2, :default => 0.0
    t.integer  "policy_term",                                                                   :default => 0
    t.integer  "premium_term",                                                                  :default => 0
    t.decimal  "modal_premium",                                  :precision => 12, :scale => 2, :default => 0.0
    t.string   "supplementary_benefit",           :limit => 45
    t.decimal  "sb_sum_assured",                                 :precision => 12, :scale => 2, :default => 0.0
    t.integer  "sb_policy_term",                                                                :default => 0
    t.integer  "sb_premium_term",                                                               :default => 0
    t.decimal  "sb_modal_premium",                               :precision => 12, :scale => 2, :default => 0.0
    t.boolean  "is_backdate",                                                                   :default => false
    t.date     "backdate"
    t.boolean  "approved",                                                                      :default => false
    t.boolean  "void",                                                                          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "current_policy_year",                                                           :default => 1
    t.string   "credit_card_number",              :limit => 20
    t.string   "credit_card_type",                :limit => 15
    t.string   "owner_name",                      :limit => 65
    t.date     "proposal_date"
    t.boolean  "deleted",                                                                       :default => false
    t.boolean  "existing_agent",                                                                :default => false
    t.date     "approval_date"
    t.integer  "shared_agent_id",                                                               :default => 0
    t.integer  "plan_id",                                                                                          :null => false
    t.boolean  "waiting_for_renewal",                                                           :default => false, :null => false
    t.string   "account_bank",                    :limit => 45,                                                    :null => false
    t.string   "account_number",                  :limit => 20,                                                    :null => false
  end

  add_index "proposals", ["agent_id"], :name => "index_proposals_on_agent_id"
  add_index "proposals", ["approval_date"], :name => "index_proposals_on_approval_date"
  add_index "proposals", ["deleted"], :name => "index_proposals_on_deleted"
  add_index "proposals", ["investor_id"], :name => "index_proposals_on_investor_id"
  add_index "proposals", ["mode_of_payment_id"], :name => "index_proposals_on_mode_of_payment_id"
  add_index "proposals", ["payment_method_id"], :name => "index_proposals_on_payment_method_id"
  add_index "proposals", ["shared_agent_id"], :name => "index_proposals_on_shared_agent_id"
  add_index "proposals", ["waiting_for_renewal"], :name => "index_proposals_on_waiting_for_renewal"

  create_table "proposed_people", :force => true do |t|
    t.integer  "proposal_id", :default => 0
    t.integer  "proposer_id", :default => 0
    t.boolean  "is_agent",    :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "proposed_people", ["proposal_id"], :name => "index_proposed_people_on_proposal_id"
  add_index "proposed_people", ["proposer_id"], :name => "index_proposed_people_on_proposer_id"

  create_table "proposers", :force => true do |t|
    t.string   "fullname",                    :limit => 100
    t.string   "new_ic_number",               :limit => 12
    t.string   "old_ic_number",               :limit => 12
    t.string   "birth_certificate",           :limit => 20
    t.string   "passport",                    :limit => 20
    t.date     "date_of_birth"
    t.integer  "age",                                                                       :default => 18
    t.text     "resident_address"
    t.string   "residence_postcode",          :limit => 12
    t.string   "residence_city",              :limit => 45
    t.string   "residence_state",             :limit => 45
    t.string   "residence_phone_number",      :limit => 12
    t.string   "mobile_number",               :limit => 12
    t.string   "company_name",                :limit => 100
    t.text     "company_address"
    t.string   "company_postcode",            :limit => 5
    t.string   "company_city",                :limit => 45
    t.string   "company_state",               :limit => 45
    t.string   "company_phone_number",        :limit => 12
    t.string   "relationship",                :limit => 45
    t.integer  "height",                                                                    :default => 0
    t.integer  "weight",                                                                    :default => 0
    t.string   "email",                       :limit => 45
    t.string   "gender",                      :limit => 6
    t.integer  "nationality_id",                                                            :default => 0
    t.string   "marital_status",              :limit => 20
    t.integer  "race_id",                                                                   :default => 0
    t.integer  "religion_id",                                                               :default => 0
    t.string   "occupation",                  :limit => 45
    t.string   "exact_duties",                :limit => 45
    t.string   "nature_of_business",          :limit => 45
    t.decimal  "annual_income",                              :precision => 12, :scale => 2
    t.boolean  "smoke_in_last_twelve_months",                                               :default => false
    t.integer  "volume_cigarettes_per_day",                                                 :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "proposers", ["nationality_id"], :name => "index_proposers_on_nationality_id"
  add_index "proposers", ["race_id"], :name => "index_proposers_on_race_id"
  add_index "proposers", ["religion_id"], :name => "index_proposers_on_religion_id"

  create_table "races", :force => true do |t|
    t.string   "name",        :limit => 45
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "religions", :force => true do |t|
    t.string   "name",        :limit => 45
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "services_chargers", :force => true do |t|
    t.string   "entry_title",         :limit => 45
    t.text     "entry_description"
    t.string   "renewal_title",       :limit => 45
    t.text     "renewal_description"
    t.decimal  "entry_amount",                      :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "renewal_amount",                    :precision => 10, :scale => 2, :default => 0.0
    t.date     "start_from"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "services_chargers", ["end_date"], :name => "index_services_chargers_on_end_date"
  add_index "services_chargers", ["start_from"], :name => "index_services_chargers_on_start_from"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "settings", :force => true do |t|
    t.string   "agent_prefix_code",                 :limit => 5,  :default => "HK"
    t.integer  "agent_last_no",                                   :default => 10000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "admin_email",                       :limit => 45
    t.integer  "agent_open_registration_level",     :limit => 1,  :default => 0,     :null => false
    t.date     "last_reminder_date"
    t.date     "last_expiry_check_date"
    t.boolean  "block_registration",                              :default => false
    t.boolean  "agent_code_follow_proposal",                      :default => false
    t.boolean  "use_proposal_number_as_agent_code",               :default => true,  :null => false
  end

  create_table "sub_commissions", :force => true do |t|
    t.integer  "term",                                       :default => 0
    t.integer  "policy_year",                                :default => 0
    t.decimal  "percentage",  :precision => 10, :scale => 2, :default => 0.0
    t.integer  "plan_id",                                    :default => 0,   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username",      :limit => 45
    t.string   "fullname",      :limit => 45
    t.string   "email",         :limit => 45
    t.boolean  "suspend",                     :default => false
    t.string   "password_hash"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
