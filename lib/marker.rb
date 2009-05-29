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
    
    def set_value(attribute, value)
      @value[attribute] = value
    end
  end
end