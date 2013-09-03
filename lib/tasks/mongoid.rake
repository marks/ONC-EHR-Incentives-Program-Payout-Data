namespace :db do
	namespace :mongoid do

		task :create_indexes do
			Mongoid.models.each do |model|
				puts "About to create indexes for model #{model}"
				model.create_indexes
			end
		end
	end
end