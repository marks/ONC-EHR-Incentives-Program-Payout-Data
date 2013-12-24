APP_FILE  = 'app.rb'
APP_CLASS = 'Sinatra::Application'

require "./#{APP_FILE}"
require 'sinatra/assetpack/rake'

# Load rake tasks from the lib/tasks/ files/folders
Dir["#{File.dirname(__FILE__)}/lib/tasks/**/*.rake"].sort.each do |ext|
  load ext
end
