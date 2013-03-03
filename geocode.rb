require 'rubygems'
require 'bundler'
require 'open-uri'
Bundler.require

require './helpers.rb'

DSTK_HOST = "ec2-54-235-43-111.compute-1.amazonaws.com" # "www.datasciencetoolkit.org"

# configure and set up MongoDB connection
mongo_client = Mongo::MongoClient.new("localhost", 27017)
onc_db = mongo_client.db("onc")
providers_col = onc_db.collection("paid_by_ehr_program")

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
