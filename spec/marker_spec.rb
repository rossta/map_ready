require File.dirname(__FILE__) + '/spec_helper'

describe MapReady::Marker do
  it "should set a lat" do
    MapReady::Marker.new(12.345, -98.765).lat.should == 12.345
  end
  it "should set a lng" do
    MapReady::Marker.new(12.345, -98.765).lng.should == -98.765
  end
  it "should be clustered when constructed with cluster array" do
    MapReady::Marker.new(0, 0, :cluster => [1]).clustered?.should be_true
  end
  it "should expose the id when constructed with an id option" do
    MapReady::Marker.new(0, 0, :id => 5).id.should == 5
  end
end
