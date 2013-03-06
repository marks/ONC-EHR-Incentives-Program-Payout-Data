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
    # static asset from S3/cf
    @data_url = '/data/ProvidersPaidByEHRProgram_Dec2012_HOSP_FINAL.geojson'
  else
    # dynamic
    @data_url = '/db/onc/ProvidersPaidByEHRProgram_Dec2012_HOSP_FINAL.geojson'
  end
  haml :main
end

get '/db/onc/ProvidersPaidByEHRProgram_Dec2012_HOSP_FINAL.geojson' do
  content_type :json

  cache_key = "hospitals"
  @geojson ||= settings.cache.fetch(cache_key) do
    geojson = Hash.new
    geojson["type"] = "FeatureCollection"
    geojson["features"] = Hospital.where("geo" => {"$ne" => nil}).map {|h| to_geojson_point(h,["geo","hcahps"])}
    settings.cache.set("hospitals", geojson, 4000)
    geojson
  end

  return @geojson.to_json
end
