require 'bundler'
Bundler.require
require 'open-uri'
require './helpers'
require './models'
require "sinatra/config_file"
require "sinatra/reloader" if development?

config_file './config/app.yml'

configure :production do
  enable :sessions
  set :session_secret, rand(36**10).to_s(36)
  set :raise_errors, false
  set :show_exceptions, false
  use Rack::Deflater
end

assets do
  css :application, '/static/min.css', [
    '/zurb-foundation-4.0.3/css/normalize.css',
    '/zurb-foundation-4.0.3/css/foundation.css',
    '/leaflet-0.5.1/leaflet.css',
    '/Leaflet.markercluster/MarkerCluster.css',
    '/Leaflet.markercluster/MarkerCluster.Default.css',
    '/bradvin-FooTable-master/css/footable-0.1.css',
    '/stefanocudini-leaflet-search/leaflet-search.css',
    '/app/main.css'
  ]

  js :application, '/static/min.js', [
    '/zurb-foundation-4.0.3/js/vendor/custom.modernizr.js',
    '/leaflet-0.5.1/leaflet.js',
    '/Leaflet.markercluster/leaflet.markercluster-src.js',
    '/bradvin-FooTable-master/js/footable-0.1.js',
    '/bradvin-FooTable-master/js/footable.sortable.js',
    '/stefanocudini-leaflet-search/leaflet-search.js',
    '/app/main.js'
  ]

  js :foundation_all, '/static/foundation_all.min.js', [
    "/zurb-foundation-4.0.3/js/foundation.min.js",
    "/zurb-foundation-4.0.3/js/foundation/foundation.js",
    "/zurb-foundation-4.0.3/js/foundation/foundation.alerts.js",
    "/zurb-foundation-4.0.3/js/foundation/foundation.clearing.js",
    "/zurb-foundation-4.0.3/js/foundation/foundation.cookie.js",
    "/zurb-foundation-4.0.3/js/foundation/foundation.dropdown.js",
    "/zurb-foundation-4.0.3/js/foundation/foundation.forms.js",
    "/zurb-foundation-4.0.3/js/foundation/foundation.joyride.js",
    "/zurb-foundation-4.0.3/js/foundation/foundation.magellan.js",
    "/zurb-foundation-4.0.3/js/foundation/foundation.orbit.js",
    "/zurb-foundation-4.0.3/js/foundation/foundation.placeholder.js",
    "/zurb-foundation-4.0.3/js/foundation/foundation.reveal.js",
    "/zurb-foundation-4.0.3/js/foundation/foundation.section.js",
    "/zurb-foundation-4.0.3/js/foundation/foundation.tooltips.js",
    "/zurb-foundation-4.0.3/js/foundation/foundation.topbar.js"
  ]
end

get '/' do
  # if settings.production? # static asset from AWS S3/CF
  #   @default_data_url = '/data/ProvidersPaidByEHRProgram_June2013_EH/ProvidersPaidByEHRProgram_June2013_EH-all_with_geo.geojson'
  # else
    @default_data_url = '/db/cms_incentives/EH/all_hospitals_with_geo.geojson'
  # end
  haml :main
end

get '/db/cms_incentives/EP/:state.geojson' do
  content_type :json
  state_geojson = Provider.with_geo.where("PROVIDER STATE" => params[:state]).map {|p| to_geojson_point(p)}
  state_geojson.to_json
end

get '/db/cms_incentives/EH/all_hospitals_with_geo.geojson' do
  content_type :json
  geojson = Hash.new
  geojson["type"] = "FeatureCollection"
  geojson["features"] = Hospital.with_geo.map {|h| to_geojson_point(h,["geo","hcahps"])}
  return geojson.to_json
end

get '/db/cms_incentives/EH/find_by_ccn/:provider_ccn.json' do
  content_type :json
  provider = Hospital.find_by("PROVIDER CCN" => params[:provider_ccn].to_s)
  if provider
    provider = provider.as_document.to_hash
    provider.delete("geo")
    # HCAHPS-specific
    if provider["hcahps"]
      provider["hcahps"]["source"] = "API endpoint of https://data.medicare.gov/dataset/Survey-of-Patients-Hospital-Experiences-HCAHPS-/rj76-22dk ; Data last fetched at #{provider["hcahps"]["_updated_at"]}"
      provider["hcahps"].delete("_updated_at")
      provider["hcahps"].delete("_source")
    end
  end

  return provider.nil? ? nil.to_json : provider.to_json
end
