require "step_by_step"

# Establish a connection to db
ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: File.dirname(__FILE__) + "/step_by_step.sqlite3"
)

# Load schema every time the specs are run
load File.dirname(__FILE__) + '/support/schema.rb'
