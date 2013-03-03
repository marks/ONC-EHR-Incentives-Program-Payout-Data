Mongoid.load!("config/mongoid.yml")

class Hospital
  include Mongoid::Document
  store_in collection: "ProvidersPaidByEHRProgram_Dec2012_HOSP_FINAL"
end

class Provider
  include Mongoid::Document
  store_in collection: "ProvidersPaidByEHRProgram_Dec2012_EP_FINAL"
end
