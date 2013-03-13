APP_FILE  = 'web_app.rb'
APP_CLASS = 'Sinatra::Application'

require './web_app.rb'
require 'sinatra/assetpack/rake'

# Load rake tasks from the lib/tasks/ files/folders
Dir["#{File.dirname(__FILE__)}/lib/tasks/**/*.rake"].sort.each do |ext|
  load ext
end
