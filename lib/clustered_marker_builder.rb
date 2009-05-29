module MapReady
  class ClusteredMarkerBuilder
  
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
end