require 'bundler'
Bundler.require
require 'open-uri'
require './helpers'
require './models'

configure do
  enable :sessions
  set :session_secret, rand(36**10).to_s(36)
  set :raise_errors, false
  set :show_exceptions, false
  set :cache, Dalli::Client.new
end

configure :development do
  PUBLIC_HOST = ""
end

configure :production do
  PUBLIC_HOST = "http://s3.amazonaws.com/hitech-vis"
end

get '/' do
  if settings.production?
    @data_url = '/data/ProvidersPaidByEHRProgram_Dec2012_HOSP_FINAL.geojson'
  else
    @data_url = '/db/onc/ProvidersPaidByEHRProgram_Dec2012_HOSP_FINAL.geojson'
  end
  haml :layout
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

# WAY TOO much data to show all providers at once
# get '/providers' do
#   if settings.production?
#     @data_url = '/data/ProvidersPaidByEHRProgram_Dec2012_EP_FINAL.geojson'
#   else
#     @data_url = '/db/onc/ProvidersPaidByEHRProgram_Dec2012_EP_FINAL.geojson'
#   end
#   haml :geojson
# end
# get '/db/onc/ProvidersPaidByEHRProgram_Dec2012_EP_FINAL.geojson' do
#   content_type :json
#   geojson = Hash.new
#   geojson["type"] = "FeatureCollection"
#   geojson["features"] = Provider.where("PROVIDER STATE" => "Texas").map {|p| to_geojson_point(p)}
#   return geojson.to_json
# end
