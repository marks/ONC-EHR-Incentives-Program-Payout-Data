require 'bundler'
Bundler.require()
require 'open-uri'
require "sinatra/config_file"
config_file './config/app.yml'
require "sinatra/reloader" if development?

require './helpers'
require './models'

configure :production do
  enable :sessions
  set :session_secret, rand(36**10).to_s(36)
  set :raise_errors, false
  set :show_exceptions, false
  set :static_cache_control, [:public, :max_age => settings.cache_time] # cache static assets for two hours 
  use Rack::Deflater

  before do
    expires settings.cache_time, :public
  end
end

assets do
  css :application, '/static/min.css', [
    '/zurb-foundation-4.3.1/css/normalize.css',
    '/zurb-foundation-4.3.1/css/foundation.css',
    '/zurb-foundation-4.3.1/css/accessibility_foundicons.css',
    '/zurb-foundation-4.3.1/css/general_foundicons.css',
    '/leaflet-0.6.4/leaflet.css',
    '/Leaflet.markercluster/dist/MarkerCluster.css',
    '/Leaflet.markercluster/dist/MarkerCluster.Default.css',
    '/stefanocudini-leaflet-search/leaflet-search.css',
    '/showLoading/showLoading.css',
    '/jquery-ui/jquery-ui.css',
    '/app/main.css'
  ]

  js :application, '/static/min.js', [
    '/zurb-foundation-4.3.1/js/vendor/custom.modernizr.js',
    '/leaflet-0.6.4/leaflet.js',
    '/Leaflet.markercluster/dist/leaflet.markercluster-src.js',
    '/stefanocudini-leaflet-search/leaflet-search.js',
    '/jquery.fastLiveFilter.js',
    '/leaflet.zoomdisplay.js',
    '/showLoading/jquery.showLoading.min.js',
    '/jquery-ui/jquery-ui.js',
    '/app/main.js'
  ]

  js :foundation_all, '/static/foundation_all.min.js', [
    "/zurb-foundation-4.3.1/js/vendor/jquery.js",
    "/zurb-foundation-4.3.1/js/foundation.min.js",
    "/zurb-foundation-4.3.1/js/foundation/foundation.js",
    "/zurb-foundation-4.3.1/js/foundation/foundation.alerts.js",
    "/zurb-foundation-4.3.1/js/foundation/foundation.clearing.js",
    "/zurb-foundation-4.3.1/js/foundation/foundation.cookie.js",
    "/zurb-foundation-4.3.1/js/foundation/foundation.dropdown.js",
    "/zurb-foundation-4.3.1/js/foundation/foundation.forms.js",
    "/zurb-foundation-4.3.1/js/foundation/foundation.joyride.js",
    "/zurb-foundation-4.3.1/js/foundation/foundation.magellan.js",
    "/zurb-foundation-4.3.1/js/foundation/foundation.orbit.js",
    "/zurb-foundation-4.3.1/js/foundation/foundation.placeholder.js",
    "/zurb-foundation-4.3.1/js/foundation/foundation.reveal.js",
    "/zurb-foundation-4.3.1/js/foundation/foundation.section.js",
    "/zurb-foundation-4.3.1/js/foundation/foundation.tooltips.js",
    "/zurb-foundation-4.3.1/js/foundation/foundation.topbar.js",
  ]
end

get '/' do
  # if settings.production?
    @all_hospitals_with_geo_url = "#{settings.public_host}/data/ProvidersPaidByEHRProgram_Sep2013_EH/geojson/all.geojson"
    @state_providers_url = "#{settings.public_host}/data/ProvidersPaidByEHRProgram_Sep2013_EP/geojson/"
  # else
  #   @all_hospitals_with_geo_url = "/db/cms_incentives/EH/all.geojson"
  #   @state_providers_url = "/db/cms_incentives/EP/"    
  # end
  haml :main
end

get '/db/cms_incentives/EP/:state.geojson' do
  content_type :json
  state_geojson = Provider.with_geo.where("PROVIDER STATE" => params[:state]).map {|p| p.to_geojson}
  state_geojson.to_json
end

get '/db/cms_incentives/EH/all.geojson' do
  content_type :json
  geojson = Hash.new
  geojson["type"] = "FeatureCollection"
  features = Hospital.with_geo.without(Hospital.exclude_from_geojson)
  geojson["features"] = features.map {|h| h.to_geojson}
  return geojson.to_json
end

get '/db/cms_incentives/EH/find_by_bson_id/:bson_id.json' do
  content_type :json
  if params[:bson_id] == "random"
    provider = Hospital.skip(rand(Hospital.count-1)).first
  else
    provider = Hospital.find(params[:bson_id])
  end
  return provider.nil? ? nil.to_json : provider.as_json.to_json
end
