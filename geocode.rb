require 'rubygems'
require 'bundler'

Bundler.require

# configure and set up MongoDB connection
mongo_client = Mongo::MongoClient.new("localhost", 27017)
onc_db = mongo_client.db("onc")
provider_col = onc_db.collection("paid_by_ehr_program")

# configure and set up Cloudmade connection using "Web Free" API key belonging to mark@socialhealthinsights.com
cloudmade = CloudMade::Client.from_parameters('ed5940a5e0724173aba9da0d77368912')


puts "Number of providers in collection: #{provider_col.count}"

# find providers without geo info and populate using Cloudmate
provider_col.find("geo" => nil).limit(10000).skip(1).each do |p|
  address_to_lookup = "#{p["PROVIDER  ADDRESS"]}, #{p["PROVIDER CITY"]}, #{p["PROVIDER STATE"]} #{p["PROVIDER ZIP 5 CD"]}"
  puts address_to_lookup
  begin # sometimes cloudmade doesnt respond nicely
    geo_result = cloudmade.geocoding.find(address_to_lookup.gsub(/[^a-zA-Z\d\s,]/,"")).results.first # cloudmade cant handle special characters in the query and we're only interested in the first result.
    geo_data = {
      "provider" => "CloudMade",
      "updated_at" => Time.now,
      "properties" => geo_result.properties,
      "centroid" => [geo_result.centroid.lat, geo_result.centroid.lon]
    }
    p["geo"] = geo_data
    provider_col.update({"_id" => p["_id"]}, p)
    puts "Updated"
  rescue
    # just move on for now, we'll geocode this provider later
  end
end
