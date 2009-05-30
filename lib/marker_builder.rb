module MapReady

  VERSION = "0.1"
  
  class Map
    DEFAULT_ZOOM = 4
    MAX_MARKERS = 100
    MAX_LOCATIONS = 5000
  
    US_CENTER_LAT = 36.209874
    US_CENTER_LNG = -98.560706
    US_CENTER_LAT_LNG = [US_CENTER_LAT, US_CENTER_LNG]
    US_SOUTHWEST_LAT_LNG = [17.5602465032949, -140.185546875]
    US_NORTHEAST_LAT_LNG = [56.75272287205734, -56.865234375]
    US_BOUNDS = Geokit::Bounds.new(Geokit::LatLng.normalize(US_SOUTHWEST_LAT_LNG), Geokit::LatLng.normalize(US_NORTHEAST_LAT_LNG))
  end
  
  class Marker
    attr_accessor :lat, :lng
    attr_reader :value
    
    def initialize(lat, lng, opts = {})
      @lat = lat
      @lng = lng
      @value = opts
    end
    
    def []=(key, value)
      @value[key] = value
    end
    
    def [](key)
      @value[key]
    end
  end
  
  module MarkerBuilder

    class Clusterable

      def initialize(mappables, opts = {})
        @mappables = mappables
        @bounds = opts[:bounds] || Map::US_BOUNDS
        @max_markers = opts[:max_markers] || Map::MAX_MARKERS
        @limit = opts[:limit] || Map::MAX_LOCATIONS
      end

      def create_markers
        cluster_grid = ClusterGrid.new(@bounds, @max_markers)
        Mappable.send(:preload_associations, @mappables, :attachable)
        Mappable.send(:preload_associations, @mappables, :geocoding)

        loop do
          cluster_grid.clear_all
          cluster_grid.increment_cluster_size

          @mappables.each do |mappable|
            next if mappable.lat.nil? || mappable.lng.nil?
            next unless @bounds.contains?(mappable)

            cluster_location = cluster_grid.snap_to_grid(mappable)
            cluster_grid[cluster_location] ||= Cluster.new
            cluster_grid[cluster_location] << mappable
          end

          break unless cluster_grid.length > @max_markers
        end

        cluster_grid.to_markers
      end

      class Cluster
        def initialize
          @mappables = Array.new
        end

        def <<(mappable)
          @mappables << mappable
        end

        def lat
          @mappables.inject(0) {|sum, map| sum + map.lat} / @mappables.size
        end

        def lng
          @mappables.inject(0) {|sum, map| sum + map.lng} / @mappables.size
        end

        def size
          @mappables.size
        end

        def mappables
          @mappables
        end

        def to_marker
          if size == 1
            mappables.first.to_marker
          else
            opts = {}
            opts[:cluster] = @mappables.map(&:marker_id)
            Marker.new(lat, lng, opts)
          end
        end

      end

      class ClusterGrid
        attr_reader :bounds

        def initialize(bounds, max_markers = Map::MAX_MARKERS)
          @bounds = bounds
          @max_markers = max_markers
          @grid = Hash.new
          @lat_size = 0
          @lng_size = 0
        end

        def to_markers
          result = []
          @grid.each_value do |cluster|
            result << cluster.to_marker
          end
          result
        end

        def []=(location, cluster)
          @grid[location] = cluster
        end

        def [](location)
          @grid[location]
        end

        def length
          @grid.length
        end

        def clear_all
          @grid.clear
        end

        def increment_cluster_size
          @lat_size += lat_increment
          @lng_size += lng_increment
        end

        def snap_to_grid(mappable)
          cluster_num_y = ((mappable.lat - south) / @lat_size).floor
          lat = (cluster_num_y * @lat_size) + south

          cluster_num_x = ((mappable.lng - west) / @lng_size).floor
          lng = (cluster_num_x * @lng_size) + west

          Geokit::LatLng.new(lat, lng)
        end

        def north
          @bounds.ne.lat
        end

        def east
          @bounds.ne.lng
        end

        def south
          @bounds.sw.lat
        end

        def west
          @bounds.sw.lng
        end

      protected

        def lng_increment
          ((east - west) / @max_markers) * 2
        end

        def lat_increment
          ((north - south) / @max_markers) * 2
        end
      end
    end
    
    class Offsetable
      SPREAD_RADIUS =  0.002#lat/lng minutes
      attr_accessor :mappables

      def initialize(mappables, user = nil)
        @mappables = mappables
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
              markers << spread_marker_for(mappable, spread_radius, opts) 
            end
          else
            mappable = mappables.first
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

    end
    
    class Simple
      def initialize(mappables)
        @mappables = mappables
      end
    
      def create_markers(opts = {})
        @mappables.map { |m| m.to_marker(opts) }
      end
    end
    
  end
end