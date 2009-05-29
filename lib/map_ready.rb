# MapReady

$:.unshift(File.dirname(__FILE__ + '.rb') + '/../lib') unless $:.include?(File.dirname(__FILE__ + '.rb') + '/../lib')
require 'activerecord'
require 'geokit'
require File.dirname(__FILE__) + "/../../geokit-rails/lib/geokit-rails/defaults.rb"
require File.dirname(__FILE__) + "/../../geokit-rails/lib/geokit-rails/acts_as_mappable.rb"
ActiveRecord::Base.send :include, GeoKit::ActsAsMappable

require "clustered_marker_builder"
require "offset_marker_builder"
require "simple_marker_builder"
require "map"
require "marker"
