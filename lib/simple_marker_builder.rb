module MapReady
  class SimpleMarkerBuilder
    def initialize(mappables)
      @mappables = mappables
    end
    
    def create_markers(opts = {})
      @mappables.map { |m| m.to_marker(opts) }
    end
  end
end