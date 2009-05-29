require File.dirname(__FILE__) + '/spec_helper'

describe MapReady::ClusteredMarkerBuilder do
  before(:each) do
    Mappable.stub!(:preload_associations)
  end
  
  describe "create_markers" do
    before(:each) do
      @locations = [
        Mappable.new(:lat => 12, :lng => 34, :marker_id => 5), 
        Mappable.new(:lat => 56, :lng => 78, :marker_id => 5)
      ]
      Mappable.stub!(:find_within_bounds).and_return(@locations)
    end

    it "should return no more than max objects" do
      MapReady::ClusteredMarkerBuilder.new(@locations, :max_markers => 1, :bounds => Geokit::Bounds.normalize([10, 30], [20, 40])).create_markers.size.should == 1
    end
    
    it "should return 1 marker for each cluster" do
      locations = [
        Mappable.new(:lat => 10, :lng => 10, :marker_id => 5), 
        Mappable.new(:lat => 20, :lng => 20, :marker_id => 5),
        Mappable.new(:lat => 30, :lng => 30, :marker_id => 5),
        Mappable.new(:lat => 40, :lng => 40, :marker_id => 5)
        ]
      MapReady::ClusteredMarkerBuilder.new(locations, :max_markers => 20, :bounds => Geokit::Bounds.normalize([0, 0],[100, 100])).create_markers.size.should == 4
    end
    
    it "should omit locations outside given bounds" do
      locations = [Mappable.new(:lat => 12, :lng => 34), Mappable.new(:lat => -56, :lng => -78)]
      MapReady::ClusteredMarkerBuilder.new(locations, :max_markers => 1, :bounds => Geokit::Bounds.normalize([-10, -30],[-20, -40])).create_markers.size.should == 0
    end
    
  end
  
  describe "Cluster" do
    before(:each) do
      @cluster = MapReady::ClusteredMarkerBuilder::Cluster.new
      @cluster << Mappable.new(:lat => 50, :lng => 100, :marker_id => 1)
      @cluster << Mappable.new(:lat => 100, :lng => 200, :marker_id => 2)
    end
    
    describe "lat" do
      it "should return mappables average lat" do
        @cluster.lat.should == 75.0
      end
    end
    
    describe "lng" do
      it "should return mappables average lng" do
        @cluster.lng.should == 150.0
      end
    end
    
    describe "to_marker" do
      context "more than one mappable" do
        it "should map mappable attachable_ids to cluster attribute" do
          children = @cluster.to_marker.value[:cluster]
          children.should include(1)
          children.should include(2)
        end
      end
    end
  end
  
  describe "ClusterGrid" do
    before(:each) do
      @grid = MapReady::ClusteredMarkerBuilder::ClusterGrid.new(Geokit::Bounds.normalize([12, 34], [56, 78]))
    end
    it "should return south" do
      @grid.south.should == 12
    end
    it "should return west" do
      @grid.west.should == 34
    end
    it "should return north" do
      @grid.north.should == 56
    end
    it "should return east" do
      @grid.east.should == 78
    end
    describe "[]=" do
      it "should set hash value" do
        @grid[:key] = [:value]
        @grid[:key].should == [:value]
      end
    end
    
    describe "to_markers" do
      before(:each) do
        @grid = MapReady::ClusteredMarkerBuilder::ClusterGrid.new(Geokit::Bounds.normalize([0, 0], [10, 10]))
      end
      
      it "should not set marker clustered for array size 1" do
        loc = Mappable.new(:lat => 5, :lng => 6, :marker_id => 5)
        cluster = MapReady::ClusteredMarkerBuilder::Cluster.new
        cluster << loc
        @grid[Geokit::LatLng.normalize(loc)] = cluster
        @grid.to_markers[0].clustered?.should be_false
      end
      
      it "should set marker marker clustered for array size > 1" do
        loc_1 = Mappable.new(:lat => 1, :lng => 2, :marker_id => 5)
        loc_2 = Mappable.new(:lat => 1, :lng => 2, :marker_id => 5)
        cluster = MapReady::ClusteredMarkerBuilder::Cluster.new
        cluster << loc_1
        cluster << loc_2
        @grid[Geokit::LatLng.normalize(loc_1)] = cluster
        @grid.to_markers[0].clustered?.should be_true
      end
      
      context "with two clusters in grid" do
        before(:each) do
          loc_1 = Mappable.new(:lat => 1, :lng => 2, :marker_id => 5)
          loc_2 = Mappable.new(:lat => 1, :lng => 2, :marker_id => 5)
          loc_3 = Mappable.new(:lat => 3, :lng => 4, :marker_id => 5)
          [loc_1, loc_2, loc_3].each do |loc|
            lat_lng = Geokit::LatLng.new(loc.lat, loc.lng)
            @grid[lat_lng] ||= MapReady::ClusteredMarkerBuilder::Cluster.new
            @grid[lat_lng] << loc
          end
        end

        it "should have a length of 2" do
          @grid.length.should == 2
        end
        
        it "should return array size of 1 marker per cluster" do
          @grid.to_markers.size.should == 2
        end
        
        it "should return array of markers" do
          @grid.to_markers[0].should be_instance_of(MapReady::Marker)
        end
      end
    end
  end  
end
