require 'rubygems'
require 'bundler'
require 'open-uri'
Bundler.require

# configure and set up MongoDB connection
mongo_client = Mongo::MongoClient.new("localhost", 27017)
onc_db = mongo_client.db("onc")
provider_col = onc_db.collection("paid_by_ehr_program")

puts "Number of providers in collection: #{provider_col.count}"

# find providers without geo info and populate using Cloudmate
provider_col.find.limit(10000).each do |p|
  address_to_lookup = "#{p["PROVIDER  ADDRESS"]}, #{p["PROVIDER CITY"]}, #{p["PROVIDER STATE"]} #{p["PROVIDER ZIP 5 CD"]}"
  puts address_to_lookup
  geo_results = JSON.parse(RestClient.get("http://www.datasciencetoolkit.org/maps/api/geocode/json?sensor=false&address="+URI.encode(address_to_lookup)))
  if geo_results["status"] == "OK"
    geo_data = {
      "provider" => "DSTK",
      "updated_at" => Time.now,
      "data" => geo_results["results"].first
    }
    p["geo"] = geo_data
    provider_col.update({"_id" => p["_id"]}, p)
    puts "Done."
  end
end
