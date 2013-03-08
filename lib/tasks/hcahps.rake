namespace :hcahps do
  SOCRATA_ENDPOINT = "http://data.medicare.gov/resource/rj76-22dk.json"
  SOCRATA_APP_TOKEN = "c1qN0TO6e65zh9oxVD6XrVJyT"

  desc "Fetch HCAHPS hospital data from Socrata API for hospitals that are already in our system (aka received incentive payments)"
  task :ingest do

    # MAP ELIGIBLE HOSPITALS (~2k)
    puts "Number of hospitals in collection: #{Hospital.count}"
    hospitals_without_hcahps = Hospital.where("hcahps.provider_number" => nil)
    puts "Number of hospitals in collection w/o HCAHPS: #{hospitals_without_hcahps.count}"

    hospitals_without_hcahps.each do |h|
      ensure_proper_ccn_format(h)
      request_url = "#{SOCRATA_ENDPOINT}?provider_number=#{h["PROVIDER CCN"]}"
      hcahps_results = JSON.parse(RestClient.get(request_url), {"X-App-Token" => SOCRATA_APP_TOKEN})
      if hcahps_results.size == 0
        puts "No hcahps data found for #{h["PROVIDER - ORG NAME"]} (CCN = #{h["PROVIDER CCN"]})"
      elsif hcahps_results.size > 1
        puts "More than one match found for #{h["PROVIDER - ORG NAME"]} (CCN = #{h["PROVIDER CCN"]})"
      else
        puts "Found HCAHPS data for #{h["PROVIDER - ORG NAME"]} (CCN = #{h["PROVIDER CCN"]})!"
        hcahps_data = {
          "_source" => request_url,
          "_updated_at" => Time.now,
        }.merge(hcahps_results.first)
        h.update_attribute("hcahps",hcahps_data)
      end
    end
  end

  desc "Add HCAHPS hospitals to datastore if they are not already in it (aka they havent received incentive payments)"
  task :add_all_hcahps_to_db do
    puts "#{Hospital.count} hospitals in db"
    all_hcahps_results = fetch_whole_socrata_dataset(SOCRATA_ENDPOINT, SOCRATA_APP_TOKEN)
    all_hcahps_results.each do |hcahps_hospital|
      ccn = hcahps_hospital["provider_number"]
      hcahps_data = {
        "_source" => SOCRATA_ENDPOINT,
        "_updated_at" => Time.now,
      }.merge(hcahps_hospital)
      Hospital.create("hcahps" => hcahps_data, "PROVIDER CCN" => ccn) if Hospital.where("PROVIDER CCN" => ccn).empty?
    end
    puts "#{Hospital.count} hospitals in db"
  end

  desc "Calculate HCAHPS national averages for each value and store in a hcahps_averages collection"
  task :calculate_national_averages do
    # find out what fields we need to calculate averages for
    array_of_fields = Hospital.where("hcahps" => {"$ne" => nil}).first["hcahps"].keys
    array_of_fields.each do |field|
      Hospital.mr_compute_descriptive_stats_excluding_nulls("hcahps.#{field}")
    end
  end

end
