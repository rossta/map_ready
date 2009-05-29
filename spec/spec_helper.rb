require "rubygems"
require "spec"
require 'ostruct'

dir = File.dirname(__FILE__)
require File.join(dir, '/../config/environment')
require File.join(dir, "/../lib/map_ready.rb")

class Mappable < ActiveRecord::Base
  acts_as_mappable
  acts_as_map_marker
end

Spec::Runner.configure do |config|
  config.before :suite do
    load File.join(dir, "../db/schema.rb")
  end
end
