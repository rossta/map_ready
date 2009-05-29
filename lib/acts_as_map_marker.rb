module MapReady
  module ActsAsMapMarker
    
    def self.included(base) # :nodoc:
      base.extend ClassMethods
      
      base.class_eval do
        belongs_to :attachable, :polymorphic => true
      end
    end

    module ClassMethods
      
      def acts_as_map_marker(options = {})
        return if !defined?(Geokit::Mappable) || self.included_modules.include?(MapReady::ActsAsMapMarker::InstanceMethods)
        send :include, MapReady::ActsAsMapMarker::InstanceMethods
      end
    end
    
    module InstanceMethods
      attr_accessor :marker_id
      
      def to_marker(opts = {})
        MapReady::Marker.new(lat, lng, opts.merge({ :id => marker_id }))
      end
    end
  end
end