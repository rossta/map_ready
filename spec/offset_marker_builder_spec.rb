require File.dirname(__FILE__) + '/spec_helper'

describe MapReady::OffsetMarkerBuilder do
  before(:each) do
    Mappable.stub!(:preload_associations)
  end
  
  describe "spread_marker_for" do
    it "should return marker with offset mappable lat and lng" do
      marker = MapReady::Marker.new(5, 10)
      mappable = Mappable.new(:lat => 5, :lng => 10)
      builder = MapReady::OffsetMarkerBuilder.new([mappable])
      radius = 2
      builder.stub!(:random_offset_within).with(radius).and_return(1)
      actual_marker = builder.spread_marker_for(mappable, radius)
      actual_marker.lat.should == 6
      actual_marker.lng.should == 11
    end
    
    it "should be nil if mappable lat is nil" do
      mappable = Mappable.new(:lat => nil)
      builder = MapReady::OffsetMarkerBuilder.new([mappable])
      builder.spread_marker_for(mappable, 1).should be_nil
    end
    
    it "should be nil if mappable lat is nil" do
      mappable = Mappable.new(:lat => 1, :lng => nil)
      builder = MapReady::OffsetMarkerBuilder.new([mappable])
      builder.spread_marker_for(mappable, 1).should be_nil
    end
  end
end
