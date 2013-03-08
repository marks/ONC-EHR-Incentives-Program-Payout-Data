namespace :hospital_general_info do

  desc "Add General Hospital Info to datastore if they are not already in it"
  task :add_all_hospitals_with_general_info do
    SOCRATA_ENDPOINT = "http://data.medicare.gov/resource/v287-28n3.json"
    SOCRATA_APP_TOKEN = "c1qN0TO6e65zh9oxVD6XrVJyT"

    puts "#{Hospital.count} hospitals in db"
    all_hospitals = fetch_whole_socrata_dataset(SOCRATA_ENDPOINT, SOCRATA_APP_TOKEN)
    all_hospitals.each do |hospital|
      ccn = hospital["provider_number"]
      hospital_data = {
        "_source" => SOCRATA_ENDPOINT,
        "_updated_at" => Time.now,
      }.merge(hospital)
      h = Hospital.where("PROVIDER CCN" => ccn)
      if h.empty?
        Hospital.create("general" => hospital_data, "PROVIDER CCN" => ccn)
      else
        h.first.update_attribute("general",hospital_data)
      end
    end
    puts "#{Hospital.count} hospitals in db"
  end

end
