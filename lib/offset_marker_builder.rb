module MapReady
  class OffsetMarkerBuilder
    SPREAD_RADIUS =  0.002#lat/lng minutes
    
    def initialize(mappables, user = nil)
      @mappables = mappables
      @user = user
    end
    
    def create_markers(opts = {})
      markers = []
      Mappable.send(:preload_associations, @mappables, :geocoding)
      Mappable.send(:preload_associations, @mappables, :attachable)
      mappables_by_geocoding = @mappables.group_by(&:geocoding_id)
      mappables_by_geocoding.to_hash.values.each do |mappables|
        if mappables.size > 1
          spread_radius = SPREAD_RADIUS * Math.sqrt(mappables.size / Math::PI)
          mappables.each do |mappable| 
            opts = merge_organizer_for(mappable.attachable, opts)
            markers << spread_marker_for(mappable, spread_radius, opts) 
          end
        else
          mappable = mappables.first
          opts = merge_organizer_for(mappable.attachable, opts)
          markers << mappable.to_marker(opts)
        end
      end
      
      markers.flatten.compact
    end
    
    def spread_marker_for(mappable, spread_radius, opts = {})
      return if mappable.lat.nil? || mappable.lng.nil?
      marker = mappable.to_marker(opts)
      marker.lat += random_offset_within(spread_radius)
      marker.lng += random_offset_within(spread_radius)
      marker
    end
    
  protected
    
    def random_offset_within(pixels)
      (rand * pixels) - (rand * pixels)
    end
    
    def merge_organizer_for(attachable, opts)
      opts.merge!({ :organizer => @user.organizer_of?(attachable)}) if @user
      opts
    end
  end
end