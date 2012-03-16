require 'rubygems'
require 'bundler/setup'

require 'dvr'
require 'active_record'
require 'with_model'
require 'ap'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ":memory:")

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.extend WithModel

  DVR.fixtures_path = File.join(File.dirname(__FILE__), 'fixtures', 'dvr')
end
