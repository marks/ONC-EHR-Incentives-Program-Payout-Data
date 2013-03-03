require 'rubygems'
require 'bundler'

Bundler.require

include Mongo
mongo_client = MongoClient.new("localhost", 27017)
onc_db = mongo_client.db("onc")
provider_col = onc_db.collection("paid_by_ehr_program")

puts "Number of providers in collection: #{provider_col.count}"
