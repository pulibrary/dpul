# frozen_string_literal: true

require "pry-byebug"
require "simplecov"
require "capybara/rspec"
require 'capybara-screenshot/rspec'
require "selenium-webdriver"
require 'webmock/rspec'

SimpleCov.start('rails') do
  add_filter 'app/mailers/application_mailer.rb'
  add_filter 'spec'
end

SimpleCov.minimum_coverage 100

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    config.example_status_persistence_file_path = "tmp/rspec_examples.txt"
  end
end
