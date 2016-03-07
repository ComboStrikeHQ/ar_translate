# frozen_string_literal: true
if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

require 'ar_translate'
require_relative 'db_schema'
require_relative 'db_models'

RSpec.configure do |config|
  config.before(:suite) do
    ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))
    silence_stream(STDOUT) do
      ActiveRecord::Schema.define(version: 0, &DB_SCHEMA)
    end
  end
end
