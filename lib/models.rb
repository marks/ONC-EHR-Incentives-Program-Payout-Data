require 'csv'

# Initialize MongoDB connection using Mongoid
Mongoid.load!(settings.mongoid_config_file)
Mongoid.raise_not_found_error = false

require_relative 'models/model_helpers.rb'
require_relative 'models/descriptive_statistic.rb'
require_relative 'models/hospital.rb'
require_relative 'models/npi.rb'
require_relative 'models/provider.rb'