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
end

configure :development do
  PUBLIC_HOST = ""
end

configure :production do
  PUBLIC_HOST = "http://cf.hitech.socialhealthinsights.com"
end

get '/' do
  if settings.production? # static asset from AWS S3/CF
    @default_data_url = '/data/all_hospitals_with_geo.geojson'
  else
    @default_data_url = '/db/onc/ProvidersPaidByEHRProgram_Dec2012_HOSP_FINAL/all_hospitals_with_geo.geojson'
  end
  haml :main
end

get '/db/onc/ProvidersPaidByEHRProgram_Dec2012_HOSP_FINAL/all_hospitals_with_geo.geojson' do
  content_type :json
  geojson = Hash.new
  geojson["type"] = "FeatureCollection"
  geojson["features"] = Hospital.where("geo" => {"$ne" => nil}).map {|h| to_geojson_point(h,["geo","hcahps"])}
  return geojson.to_json
end

get '/db/onc/ProvidersPaidByEHRProgram_Dec2012_HOSP_FINAL/find_by_ccn/:provider_ccn.json' do
  content_type :json
  providers = Hospital.limit(1).where("PROVIDER CCN" => params[:provider_ccn].to_s)
  return nil if providers.empty?

  provider = providers[0].as_document.to_hash
  provider.delete("geo")
  # HCAHPS-specific
  provider["hcahps"]["source"] = "API endpoint of https://data.medicare.gov/dataset/Survey-of-Patients-Hospital-Experiences-HCAHPS-/rj76-22dk ; Data last fetched at #{provider["hcahps"]["_updated_at"]}"
  provider["hcahps"].delete("_updated_at")
  provider["hcahps"].delete("_source")

  return provider.nil? ? nil.to_json : provider.to_json
end
