Mongoid.load!("config/mongoid.yml")

class Hospital
  include Mongoid::Document
  index({ "PROVIDER STATE" => 1})
  index({ "geo.data.geometry.location" => "2d"})
  store_in collection: "ProvidersPaidByEHRProgram_Dec2012_HOSP_FINAL"
end

class Provider
  include Mongoid::Document
  index({ "PROVIDER STATE" => 1})
  index({ "geo.data.geometry.location" => "2d"})
  store_in collection: "ProvidersPaidByEHRProgram_Dec2012_EP_FINAL"
end
