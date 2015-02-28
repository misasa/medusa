require 'spec_helper'

describe "records routing" do
  it { expect(:get => '/records/1111.json').to route_to(:controller => "records", :action => "show", :id => "1111", :format => "json") }
  it { expect(:get => '/records/1111.pml').to route_to(:controller => "records", :action => "show", :id => "1111", :format => "pml") }
end
