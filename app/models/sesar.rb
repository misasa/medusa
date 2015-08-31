require "active_resource"

class Sesar < ActiveResource::Base
  self.site = "http://app.geosamples.org/"
  self.prefix = "/sample/"
  self.element_name = "sample"
  self.collection_name = "igsn"
  self.format = :xml
  self.headers["Accept"] = "application/xml"

  def self.find(*arguments)
    super
  rescue ActiveResource::Redirection => e
    find(:one, from: e.response["location"])
  end
end
