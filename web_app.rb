require 'bundler'
Bundler.require
require 'open-uri'
require './helpers'
require './models'

class MUMaps < Sinatra::Base

  get '/' do
    @data_url = '/db/onc/ProvidersPaidByEHRProgram_Dec2012_HOSP_FINAL.geojson'
    haml :geojson
  end

  get '/db/onc/ProvidersPaidByEHRProgram_Dec2012_HOSP_FINAL.geojson' do
    content_type :json
    geojson = Hash.new
    geojson["type"] = "FeatureCollection"
    geojson["features"] = Hospital.where("geo" => {"$ne" => nil}).map {|h| to_geojson_point(h)}
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
    geojson["features"] = Provider.where("geo" => {"$ne" => nil}).limit(5000).map {|p| to_geojson_point(p)}
    return geojson.to_json
  end

end
