namespace :hospitals do
  SOCRATA_APP_TOKEN = "c1qN0TO6e65zh9oxVD6XrVJyT"

  desc "Add General Hospital Info to datastore if they are not already in it"
  task :ingest_general_info do
    puts "#{Hospital.count} hospitals in db"

    socrata_endpoint = "http://data.medicare.gov/resource/v287-28n3.json"
    all_hospitals = fetch_whole_socrata_dataset(socrata_endpoint, SOCRATA_APP_TOKEN)

    puts "Ingesting new data"
    all_hospitals.each do |hospital|
      ccn = hospital["provider_number"]
      hospital_data = {
        "_source" => socrata_endpoint,
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
    socrata_endpoint = "http://data.medicare.gov/resource/rj76-22dk.json"

    puts "Number of hospitals in collection: #{Hospital.count}"
    hospitals_without_hcahps = Hospital.without_hcahps
    puts "Number of hospitals in collection w/o HCAHPS: #{hospitals_without_hcahps.count}"

    hcahps_data = fetch_whole_socrata_dataset(socrata_endpoint, SOCRATA_APP_TOKEN)

    puts "Ingesting new data"
    hcahps_data.each do |hospital|
      ccn = hospital["provider_number"]
      hcahps_data = {
        "_source" => socrata_endpoint,
        "_updated_at" => Time.now,
      }.merge(hospital)
      h = Hospital.where("PROVIDER CCN" => ccn)
      if h.empty?
        Hospital.create("hcahps" => hcahps_data, "PROVIDER CCN" => ccn)
      else
        h.first.update_attribute("hcahps",hcahps_data)
      end
    end
    
    puts "#{Hospital.count} hospitals in db"
    puts "Number of hospitals in collection w/o HCAHPS: #{Hospital.without_hcahps.count}"
  end

  #desc "Calculate HCAHPS national averages for each value and store in a hcahps_averages collection"
  #task :calculate_national_averages do
  #  # find out what fields we need to calculate averages for
  #  array_of_fields = Hospital.where("hcahps" => {"$ne" => nil}).first["hcahps"].keys
  #  array_of_fields.each do |field|
  #    Hospital.mr_compute_descriptive_stats_excluding_nulls("hcahps.#{field}")
  #  end
  #end

  task :simple_report do
    puts "We started by analyzing hospitals that received incentive payments in program year 2011, 2012, or 2013. We then added all hospitals in the hospital compare (general information) data set, and added HCAHPS data for as many hospitals as we could, using their CCN as the look up variable."
    # Documents with a root-level key of "PROGRAM YEAR 2012" DID receive incentive payments
    puts "# of hospitals in db = #{Hospital.count}"
    recvd_incentive = Hospital.received_any_incentives
    puts "  # recvd_incentive = #{recvd_incentive.count}"
    recvd_incentive_and_have_geo = recvd_incentive.with_geo
    puts "    # recvd_incentive_and_have_geo = #{recvd_incentive_and_have_geo.count}"
    recvd_incentive_and_have_hcahps = recvd_incentive.with_hcahps
    puts "    # recvd_incentive_and_have_hcahps = #{recvd_incentive_and_have_hcahps.count}"
    recvd_incentive_and_have_general = recvd_incentive.with_general
    puts "    # recvd_incentive_and_have_general = #{recvd_incentive_and_have_general.count}"
    # Documents without a root-level key of "PROGRAM YEAR 2012" did NOT recieve incentive payments
    didnt_recv_incentive = Hospital.never_received_any_incentives
    puts "  # didnt_recv_incentive = #{didnt_recv_incentive.count}"
    didnt_recv_incentive_and_have_geo = didnt_recv_incentive.with_geo
    puts "    # didnt_recv_incentive_and_have_geo = #{didnt_recv_incentive_and_have_geo.count}"
    didnt_recv_incentive_and_have_hcahps = didnt_recv_incentive.with_hcahps
    puts "    # didnt_recv_incentive_and_have_hcahps = #{didnt_recv_incentive_and_have_hcahps.count}"
    didnt_recv_incentive_and_have_general = didnt_recv_incentive.with_general
    puts "    # didnt_recv_incentive_and_have_general = #{didnt_recv_incentive_and_have_general.count}"
    puts

    puts "TOTAL HOSPITALS = #{Hospital.count}"

  end


end
