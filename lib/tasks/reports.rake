namespace :reports do

  # need to figure out how many incentive-receiving hospitals have geo, hcahps, and general info
  # how mny non-incentive recieving hospitals have geo, hcahps, and general info? (none should have geo!)

  namespace :hospitals do
    task :simple_counts do

      # Global criteria
      has_geo_crtieria = {"geo" => {"$ne" => nil}}
      has_hcahps_criteria = {"hcahps" => {"$ne" => nil}}
      has_general_criteria = {"general" => {"$ne" => nil}}



      # A) We started by analyzing locations receiving EHR incentive payment (www.cms.gov/Regulations-and-Guidance/Legislation/EHRIncentivePrograms/DataAndReports.html)
      # Documents with a root-level key of "PROGRAM YEAR 2012" DID receive incentive payments
      recvd_incentive_criteria = {"PROGRAM YEAR 2012" => {"$ne" => nil}}
      recvd_incentive = Hospital.where(recvd_incentive_criteria)
      puts "# recvd_incentive = #{recvd_incentive.count}"
      recvd_incentive_and_have_geo = recvd_incentive.where(has_geo_crtieria)
      puts "  # recvd_incentive_and_have_geo = #{recvd_incentive_and_have_geo.count}"
      recvd_incentive_and_have_hcahps = recvd_incentive.where(has_hcahps_criteria)
      puts "  # recvd_incentive_and_have_hcahps = #{recvd_incentive_and_have_hcahps.count}"
      recvd_incentive_and_have_general = recvd_incentive.where(has_general_criteria)
      puts "  # recvd_incentive_and_have_general = #{recvd_incentive_and_have_general.count}"

      print "\n"

      # Documents without a root-level key of "PROGRAM YEAR 2012" did NOT recieve incentive payments
      didnt_recv_incentive_criteria = {"PROGRAM YEAR 2012" => nil}
      didnt_recv_incentive = Hospital.where(didnt_recv_incentive_criteria)
      puts "# didnt_recv_incentive = #{didnt_recv_incentive.count}"
      didnt_recv_incentive_and_have_geo = didnt_recv_incentive.where(has_geo_crtieria)
      puts "  # didnt_recv_incentive_and_have_geo = #{didnt_recv_incentive_and_have_geo.count}"
      didnt_recv_incentive_and_have_hcahps = didnt_recv_incentive.where(has_hcahps_criteria)
      puts "  # didnt_recv_incentive_and_have_hcahps = #{didnt_recv_incentive_and_have_hcahps.count}"
      didnt_recv_incentive_and_have_general = didnt_recv_incentive.where(has_general_criteria)
      puts "  # didnt_recv_incentive_and_have_general = #{didnt_recv_incentive_and_have_general.count}"


    end
  end

end
