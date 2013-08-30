namespace :hospitals do
  SOCRATA_APP_TOKEN = "c1qN0TO6e65zh9oxVD6XrVJyT"

  desc "Add General Hospital Info to datastore if they are not already in it"
  task :ingest_general_info do

    puts "#{Hospital.count} hospitals in db"
    all_hospitals = fetch_whole_socrata_dataset(SOCRATA_ENDPOINT, SOCRATA_APP_TOKEN)
    all_hospitals.each do |hospital|
      ccn = hospital["provider_number"]
      hospital_data = {
        "_source" => "http://data.medicare.gov/resource/v287-28n3.json",
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


  desc "Fetch HCAHPS hospital data from Socrata API for hospitals that are already in our system (aka received incentive payments)"
  task :ingest_hcahps do

    # MAP ELIGIBLE HOSPITALS
    puts "Number of hospitals in collection: #{Hospital.count}"
    hospitals_without_hcahps = Hospital.where("hcahps.provider_number" => nil)
    puts "Number of hospitals in collection w/o HCAHPS: #{hospitals_without_hcahps.count}"

    hospitals_without_hcahps.each do |h|
      ensure_proper_ccn_format(h)
      request_url = "http://data.medicare.gov/resource/rj76-22dk.json?provider_number=#{h["PROVIDER CCN"]}"
      hcahps_results = JSON.parse(RestClient.get(request_url), {"X-App-Token" => SOCRATA_APP_TOKEN})
      provider_name = h["PROVIDER - ORG NAME"].blank? ? h["general"]["hospital_name"] : h["PROVIDER - ORG NAME"]
      if hcahps_results.size == 0
        puts "No hcahps data found for #{provider_name} (CCN = #{h["PROVIDER CCN"]})"
      elsif hcahps_results.size > 1
        puts "More than one match found for #{provider_name} (CCN = #{h["PROVIDER CCN"]})"
      else
        puts "Found HCAHPS data for #{provider_name} (CCN = #{h["PROVIDER CCN"]})!"
        hcahps_data = {
            "_source" => request_url,
            "_updated_at" => Time.now,
        }.merge(hcahps_results.first)
        h.update_attribute("hcahps",hcahps_data)
      end
    end
  end

  #desc "Calculate HCAHPS national averages for each value and store in a hcahps_averages collection"
  #task :calculate_national_averages do
  #  # find out what fields we need to calculate averages for
  #  array_of_fields = Hospital.where("hcahps" => {"$ne" => nil}).first["hcahps"].keys
  #  array_of_fields.each do |field|
  #    Hospital.mr_compute_descriptive_stats_excluding_nulls("hcahps.#{field}")
  #  end
  #end

  task :simple_counts do
    has_geo_crtieria = {"geo" => {"$ne" => nil}}
    has_hcahps_criteria = {"hcahps" => {"$ne" => nil}}
    has_general_criteria = {"general" => {"$ne" => nil}}
    never_recv_any_incentive_criteria = {"PROGRAM YEAR 2012" => nil, "PROGRAM YEAR 2011" => nil, "PROGRAM YEAR 2013" => nil}

    puts "We started by analyzing hospitals that received incentive payments in program year 2011, 2012, or 2013. We then added all hospitals in the hospital compare (general information) data set, and added HCAHPS data for as many hospitals as we could, using their CCN as the look up variable."
    # Documents with a root-level key of "PROGRAM YEAR 2012" DID receive incentive payments
    puts "# of hospitals in db = #{Hospital.count}"
    recvd_incentive_criteria = [{"PROGRAM YEAR 2011" => "TRUE"},{"PROGRAM YEAR 2012" => "TRUE"},{"PROGRAM YEAR 2013" => "TRUE"}]
    recvd_incentive = Hospital.any_of(recvd_incentive_criteria)
    puts "  # recvd_incentive = #{recvd_incentive.count}"
    recvd_incentive_and_have_geo = recvd_incentive.where(has_geo_crtieria)
    puts "    # recvd_incentive_and_have_geo = #{recvd_incentive_and_have_geo.count}"
    recvd_incentive_and_have_hcahps = recvd_incentive.where(has_hcahps_criteria)
    puts "    # recvd_incentive_and_have_hcahps = #{recvd_incentive_and_have_hcahps.count}"
    recvd_incentive_and_have_general = recvd_incentive.where(has_general_criteria)
    puts "    # recvd_incentive_and_have_general = #{recvd_incentive_and_have_general.count}"
    # Documents without a root-level key of "PROGRAM YEAR 2012" did NOT recieve incentive payments
    didnt_recv_incentive = Hospital.where(never_recv_any_incentive_criteria)
    puts "  # didnt_recv_incentive = #{didnt_recv_incentive.count}"
    didnt_recv_incentive_and_have_geo = didnt_recv_incentive.where(has_geo_crtieria)
    puts "    # didnt_recv_incentive_and_have_geo = #{didnt_recv_incentive_and_have_geo.count}"
    didnt_recv_incentive_and_have_hcahps = didnt_recv_incentive.where(has_hcahps_criteria)
    puts "    # didnt_recv_incentive_and_have_hcahps = #{didnt_recv_incentive_and_have_hcahps.count}"
    didnt_recv_incentive_and_have_general = didnt_recv_incentive.where(has_general_criteria)
    puts "    # didnt_recv_incentive_and_have_general = #{didnt_recv_incentive_and_have_general.count}"
    puts

    puts "TOTAL HOSPITALS = #{Hospital.count}"

  end


end
