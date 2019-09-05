require 'spec_helper'

describe "nested_spots routing" do
  it { expect(:post => '/surfaces/1111/spots.json').to route_to(:action => "create", :controller => "nested_resources/spots", :surface_id => "1111", :format => "json")}
  it { expect(:put => '/surfaces/1111/spots/2222.json').to route_to(:action => "update", :controller => "nested_resources/spots", :surface_id => "1111", :id => "2222", :format => "json")}

end
