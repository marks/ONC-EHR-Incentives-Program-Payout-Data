require 'rubygems'
require 'bundler'
require 'open-uri'
Bundler.require
require './helpers.rb'

configure do
  # configure and set up MongoDB connection
  MDB = Mongo::MongoClient.new("localhost", 27017)
  ONC = MDB.db("onc")
  HOSPITALS = ONC.collection("ProvidersPaidByEHRProgram_Dec2012_HOSP_FINAL")
  PROVIDERS = ONC.collection("ProvidersPaidByEHRProgram_Dec2012_EP_FINAL")
end

get '/hospitals' do
  @data_url = '/db/onc/ProvidersPaidByEHRProgram_Dec2012_HOSP_FINAL.geojson'
  haml :geojson
end

get '/db/onc/ProvidersPaidByEHRProgram_Dec2012_HOSP_FINAL.geojson' do
  content_type :json
  geojson = Hash.new
  geojson["type"] = "FeatureCollection"
  geojson["features"] = HOSPITALS.find("geo" => {"$ne" => nil}).map {|h| to_geojson_point(h)}
  return geojson.to_json
end

get '/providers' do
  @data_url = '/db/onc/ProvidersPaidByEHRProgram_Dec2012_EP_FINAL.geojson'
  haml :geojson
end

get '/db/onc/ProvidersPaidByEHRProgram_Dec2012_EP_FINAL.geojson' do
  content_type :json
  geojson = Hash.new
  geojson["type"] = "FeatureCollection"
  geojson["features"] = PROVIDERS.find("geo" => {"$ne" => nil}).limit(5000).map {|p| to_geojson_point(p)}
  return geojson.to_json
end
