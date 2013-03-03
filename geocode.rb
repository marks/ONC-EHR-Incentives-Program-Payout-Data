require 'rubygems'
require 'bundler'
require 'open-uri'
Bundler.require

DSTK_HOST = "ec2-54-235-43-111.compute-1.amazonaws.com" # "www.datasciencetoolkit.org"

# configure and set up MongoDB connection
mongo_client = Mongo::MongoClient.new("localhost", 27017)
onc_db = mongo_client.db("onc")
providers_col = onc_db.collection("paid_by_ehr_program")

puts "Number of providers in collection: #{providers_col.count}"

providers_without_geo = providers_col.find("geo" => nil)
puts "Number of providers in collection w/o geolocation: #{providers_without_geo.count}"

providers_without_geo.each do |p|
  address_to_lookup = "#{p["PROVIDER  ADDRESS"]}, #{p["PROVIDER CITY"]}, #{p["PROVIDER STATE"]} #{p["PROVIDER ZIP 5 CD"]}".gsub(/[^a-zA-Z\d\s,]/," ")
  puts address_to_lookup
  geo_results = JSON.parse(RestClient.get("http://#{DSTK_HOST}/maps/api/geocode/json?sensor=false&address="+URI.encode(address_to_lookup)))
  if geo_results["status"] == "OK"
    geo_data = {
      "provider" => "DSTK",
      "updated_at" => Time.now,
      "data" => geo_results["results"].first
    }
    p["geo"] = geo_data
    providers_col.update({"_id" => p["_id"]}, p)
    puts "Done."
  end
end
