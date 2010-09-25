$LOAD_PATH << File.expand_path('../../../lib', __FILE__)

ENV['AR_VERSION'] ||= '3.0'

require 'rubygems'
require 'bundler/setup'
require 'has_enumeration'

if ENV['AR_VERSION'] == '3.0'
  require 'meta_where'
end

ActiveRecord::Base.establish_connection(
  :adapter => defined?(JRUBY_VERSION) ? 'jdbcsqlite3': 'sqlite3',
  :database => File.expand_path('../database', __FILE__)
)

class CreateTables < ActiveRecord::Migration
  create_table :explicitly_mapped_models, :force => true do |t|
    t.integer :color
  end

  create_table :implicitly_mapped_models, :force => true do |t|
    t.string :color
  end

  create_table :nonstandard_attribute_models, :force => true do |t|
    t.integer :hue
  end
end
