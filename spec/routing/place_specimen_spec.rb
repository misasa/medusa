require 'spec_helper'

describe "place routing" do
  it { expect(:get => '/specimens/1111/place.json').to route_to(:controller => "specimens", :action => "show_place", :id => "1111", :format => "json") }
  it { expect(:post => '/specimens/1111/place.json').to route_to(:controller => "specimens", :action => "create_place", :id => "1111", :format => "json") }
end
