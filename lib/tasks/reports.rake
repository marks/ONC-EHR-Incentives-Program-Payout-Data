namespace :reports do

  # need to figure out how many incentive-receiving hospitals have geo, hcahps, and general info
  # how mny non-incentive recieving hospitals have geo, hcahps, and general info? (none should have geo!)

  namespace :hospitals do
    task :simple_counts do
      # Global criteria
      has_geo_crtieria = {"geo" => {"$ne" => nil}}
      has_hcahps_criteria = {"hcahps" => {"$ne" => nil}}
      has_general_criteria = {"general" => {"$ne" => nil}}

      puts "A) We started by analyzing locations receiving EHR incentive payment from www.cms.gov/Regulations-and-Guidance/Legislation/EHRIncentivePrograms/DataAndReports.html"
      # Documents with a root-level key of "PROGRAM YEAR 2012" DID receive incentive payments
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
      didnt_recv_incentive_criteria = {"PROGRAM YEAR 2012" => nil, "PROGRAM YEAR 2011" => nil}
      didnt_recv_incentive = Hospital.where(didnt_recv_incentive_criteria)
      puts "  # didnt_recv_incentive = #{didnt_recv_incentive.count}"
      didnt_recv_incentive_and_have_geo = didnt_recv_incentive.where(has_geo_crtieria)
      puts "    # didnt_recv_incentive_and_have_geo = #{didnt_recv_incentive_and_have_geo.count}"
      didnt_recv_incentive_and_have_hcahps = didnt_recv_incentive.where(has_hcahps_criteria)
      puts "    # didnt_recv_incentive_and_have_hcahps = #{didnt_recv_incentive_and_have_hcahps.count}"
      didnt_recv_incentive_and_have_general = didnt_recv_incentive.where(has_general_criteria)
      puts "    # didnt_recv_incentive_and_have_general = #{didnt_recv_incentive_and_have_general.count}"
      puts

      puts "B) Then we added HCAHPS data from https://data.medicare.gov/dataset/Survey-of-Patients-Hospital-Experiences-HCAHPS-/rj76-22dk"
      have_hcahps = Hospital.where(has_hcahps_criteria)
      puts "  # have_hcahps = #{have_hcahps.count}"
      puts


      puts "C) Then we added Hospital General Info data from https://data.medicare.gov/dataset/Hospital-General-Information/v287-28n3"
      have_general = Hospital.where(has_general_criteria)
      puts "  # have_general = #{have_general.count}"
      puts

      puts "TOTAL HOSPITALS = #{Hospital.count}"

    end
  end

end
