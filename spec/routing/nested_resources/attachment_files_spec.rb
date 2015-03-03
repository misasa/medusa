require 'spec_helper'

describe "nested_attachments routing" do
  it { expect(:get => '/stones/1111/attachment_files.json').to route_to(:parent_resource => "stone", :action => "index", :controller => "nested_resources/attachment_files", :stone_id => "1111", :format => "json")}
end
