require 'bundler'
Bundler.require
require 'open-uri'
require './helpers'
require './models'

configure do
  enable :sessions
  set :raise_errors, false
  set :show_exceptions, false
  set :cache, Dalli::Client.new
end

get '/' do
  @data_url = '/db/onc/ProvidersPaidByEHRProgram_Dec2012_HOSP_FINAL.geojson'
  haml :geojson
end

get '/db/onc/ProvidersPaidByEHRProgram_Dec2012_HOSP_FINAL.geojson' do
  content_type :json

  cache_key = "hospitals"
  @geojson ||= settings.cache.fetch(cache_key) do
    geojson = Hash.new
    geojson["type"] = "FeatureCollection"
    geojson["features"] = Hospital.where("geo" => {"$ne" => nil}).map {|h| to_geojson_point(h)}
    settings.cache.set("hospitals", geojson, 4000)
    geojson
  end

  return @geojson.to_json
end

get '/providers' do
  @data_url = '/db/onc/ProvidersPaidByEHRProgram_Dec2012_EP_FINAL.geojson'
  haml :geojson
end

get '/db/onc/ProvidersPaidByEHRProgram_Dec2012_EP_FINAL.geojson' do
  content_type :json
  geojson = Hash.new
  geojson["type"] = "FeatureCollection"
  geojson["features"] = Provider.where("geo" => {"$ne" => nil}).limit(5000).map {|p| to_geojson_point(p)}
  return geojson.to_json
end
