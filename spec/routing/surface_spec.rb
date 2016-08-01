require 'spec_helper'

describe "surface_image routing" do
  it { expect(:get => '/surfaces/1111').to route_to(:controller => "surfaces", :action => "show", :id => "1111") }
  it { expect(:get => '/surfaces/1/images/2').to route_to(:controller => "surface_images", :action => "show", :surface_id => "1", :id => "2") }

end