require 'spec_helper'

describe "nested_attachments routing" do
  it { expect(:get => '/specimens/1111/attachment_files.json').to route_to(:parent_resource => "specimen", :action => "index", :controller => "nested_resources/attachment_files", :specimen_id => "1111", :format => "json")}
end
