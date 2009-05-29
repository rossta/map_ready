module MapReady
  class Marker
    attr_accessor :lat, :lng, :value
  
    def initialize(lat, lng, opts = {})
      @lat = lat
      @lng = lng
      @value = opts
    end
  
    def clustered?
      !@value[:cluster].nil?
    end
    
    def id
      @value[:id]
    end
  end
end