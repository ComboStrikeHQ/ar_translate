require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'ar_translate'
require_relative 'db_schema'

RSpec.configure do |config|
  config.before(:suite) do
    ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))
  end

  config.before(:example) do
    silence_stream(STDOUT) do
      ActiveRecord::Schema.define(version: 0, &DB_SCHEMA)
    end

    load 'spec/db_models.rb'
  end
end
