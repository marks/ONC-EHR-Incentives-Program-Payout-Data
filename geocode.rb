require 'rubygems'
require 'bundler'
require 'open-uri'
Bundler.require

require './helpers.rb'

# configure data science toolkit host.
DSTK_HOST = "ec2-54-235-43-111.compute-1.amazonaws.com" # "www.datasciencetoolkit.org"

# configure and set up MongoDB connection
mongo_client = Mongo::MongoClient.new("localhost", 27017)
onc_db = mongo_client.db("onc")

# GEOCODE ELIGIBLE HOSPITALS (~2k)
hospitals_col = onc_db.collection("ProvidersPaidByEHRProgram_Dec2012_HOSP_FINAL")
puts "Number of hospitals in collection: #{hospitals_col.count}"
hospitals_without_geo = hospitals_col.find("geo" => nil)
puts "Number of hospitals in collection w/o geolocation: #{hospitals_without_geo.count}"

hospitals_without_geo.each do |h|
  geo_results = dstk_geocode("#{h["PROVIDER / ORG NAME"]}, #{h["PROVIDER  ADDRESS"]}, #{h["PROVIDER CITY"]}, #{h["PROVIDER STATE"]} #{h["PROVIDER ZIP 5 CD"]}")
  if geo_results
    h["geo"] = geo_results
    hospitals_col.update({"_id" => h["_id"]}, h)
  end
end

# GEOCODE ELIGIBLE PROVIDERS (~106k)
providers_col = onc_db.collection("ProvidersPaidByEHRProgram_Dec2012_EP_FINAL")
puts "Number of providers in collection: #{providers_col.count}"
providers_without_geo = providers_col.find("geo" => nil)
puts "Number of providers in collection w/o geolocation: #{providers_without_geo.count}"

providers_without_geo.each do |p|
  geo_results = dstk_geocode("#{p["PROVIDER  ADDRESS"]}, #{p["PROVIDER CITY"]}, #{p["PROVIDER STATE"]} #{p["PROVIDER ZIP 5 CD"]}")
  if geo_results
    p["geo"] = geo_results
    providers_col.update({"_id" => p["_id"]}, p)
  end
end
