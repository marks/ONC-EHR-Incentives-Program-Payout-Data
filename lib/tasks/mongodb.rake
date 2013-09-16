namespace :mongodb do

	desc "Create indexes using Mongoid-specific functionality"
	task :mongoid_create_indexes do
		Mongoid.models.each do |model|
			puts "About to create indexes for model #{model}"
			model.create_indexes
		end
	end

	desc "Export to MongoHQ"
	task :export_to_mongohq do
		db_name = Mongoid.sessions["default"]["database"]
		mongohq_url = %x(heroku config:get MONGOHQ_URL).gsub("\n","")
		mongohq_uri = URI.parse(mongohq_url)
		mongohq_db = mongohq_uri.path.gsub("/","")

		puts "Removing old mongodump from tmp/#{db_name}/"
		%x(rm tmp/#{db_name}/*)

		puts "Dumping latest local mongodb data to tmp/#{db_name}"
	  %x(mongodump -d #{db_name} -o tmp/)

	  puts "mongorestore'ing to MongoHQ"
	  %x(mongorestore -h #{mongohq_uri.host} --port #{mongohq_uri.port} -d #{mongohq_db} -u #{mongohq_uri.user} -p #{mongohq_uri.password} --drop tmp/#{db_name})
	end

end