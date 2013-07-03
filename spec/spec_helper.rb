require 'rubygems'
require 'bundler'
Bundler.require(:default, :test)

require 'rspec'

require File.expand_path('../lib/extended_has_enumeration', File.dirname(__FILE__))
require File.expand_path('../features/support/explicitly_mapped_model', File.dirname(__FILE__))
require File.expand_path('../features/support/explicitly_mapped_model_with_default', File.dirname(__FILE__))
require File.expand_path('../features/support/model_with_wrong_default', File.dirname(__FILE__))
require File.expand_path('../features/support/mapped_model_with_initial', File.dirname(__FILE__))

ActiveRecord::Base.establish_connection(
  :adapter => defined?(JRUBY_VERSION) ? 'jdbcsqlite3': 'sqlite3',
  :database => File.expand_path('../database', __FILE__)
)

if ActiveRecord::VERSION::MAJOR >= 3
  Bundler.require(:meta_where)
end

class CreateTables < ActiveRecord::Migration
  create_table :explicitly_mapped_models, :force => true do |t|
    t.string :color
  end

  create_table :explicitly_mapped_model_with_defaults, :force => true do |t|
    t.string :color
  end

  create_table :model_with_wrong_defaults, :force => true do |t|
    t.string :color
  end

  create_table :mapped_model_with_initials, :force => true do |t|
    t.string :color
  end
end
