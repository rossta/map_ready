# MapReady

$:.unshift(File.dirname(__FILE__ + '.rb') + '/../lib') unless $:.include?(File.dirname(__FILE__ + '.rb') + '/../lib')
require 'activerecord'
require 'geokit'
require 'geokit-rails'
ActiveRecord::Base.send :include, GeoKit::ActsAsMappable

require "marker_builder"
require "acts_as_map_marker"
ActiveRecord::Base.send :include, MapReady::ActsAsMapMarker

