Mongoid.load!("config/mongoid.yml")

class Hospital
  include Mongoid::Document
  index({ "PROVIDER CCN" => 1})
  index({ "PROVIDER NPI" => 1})
  index({ "PROVIDER STATE" => 1})
  index({ "geo.data.geometry.location" => "2d"})
  store_in collection: "ProvidersPaidByEHRProgram_Dec2012_HOSP_FINAL"
end

class Provider
  include Mongoid::Document
  index({ "PROVIDER NPI" => 1})
  index({ "PROVIDER STATE" => 1})
  index({ "geo.data.geometry.location" => "2d"})
  store_in collection: "ProvidersPaidByEHRProgram_Dec2012_EP_FINAL"
end

STATES = ["Alabama",  "Alaska", "Arizona",  "Arkansas", "California", "Colorado", "Connecticut",  "Delaware", "District Of Columbia", "Federated States Of Micronesia", "Florida",  "Georgia",  "Guam", "Hawaii", "Idaho",  "Illinois", "Indiana",  "Iowa", "Kansas", "Kentucky", "Louisiana",  "Maine",  "Marshall Islands", "Maryland", "Massachusetts",  "Michigan", "Minnesota",  "Mississippi",  "Missouri", "Montana",  "Nebraska", "Nevada", "New Hampshire",  "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Palau",  "Pennsylvania", "Puerto Rico",  "Rhode Island", "South Carolina", "South Dakota", "Tennessee",  "Texas",  "Utah", "Vermont","Virginia", "Washington", "West Virginia",  "Wisconsin",  "Wyoming"]
