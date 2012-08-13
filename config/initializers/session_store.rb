# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_hkventure_session',
  :secret      => '4ad3bd50b9d8446f704b7389f1391fb987fb3c08cd35ea91b9e683df786d403ec54cc3e4492d1a2527e543431521015fa9128f0b61500e01f0f38612c360cda9'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
