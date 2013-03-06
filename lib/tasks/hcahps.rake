namespace :hcahps do

  desc "Fetch from Socrata API for https://data.medicare.gov/dataset/Survey-of-Patients-Hospital-Experiences-HCAHPS-/rj76-22dk"
  task :ingest do
    SOCRATA_APP_TOKEN = "c1qN0TO6e65zh9oxVD6XrVJyT"
    SOCRATA_ENDPOINT = "http://data.medicare.gov/resource/rj76-22dk.json"

    # MAP ELIGIBLE HOSPITALS (~2k)
    puts "Number of hospitals in collection: #{Hospital.count}"
    hospitals_without_hcahps = Hospital.where("hcahps.provider_number" => nil)
    puts "Number of hospitals in collection w/o HCAHPS: #{hospitals_without_hcahps.count}"

    hospitals_without_hcahps.each do |h|
      ensure_proper_ccn_format(h)
      request_url = "#{SOCRATA_ENDPOINT}?provider_number=#{h["PROVIDER CCN"]}"
      hcahps_results = JSON.parse(RestClient.get(request_url))#, {"X-App-Token" => SOCRATA_APP_TOKEN}))
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

end
