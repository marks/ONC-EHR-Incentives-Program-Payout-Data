namespace :reports do

  # need to figure out how many incentive-receiving hospitals have geo, hcahps, and general info
  # how mny non-incentive recieving hospitals have geo, hcahps, and general info? (none should have geo!)

  namespace :hospitals do
    task :simple_counts do
      # A) We started by analyzing locations receiving EHR incentive payment (www.cms.gov/Regulations-and-Guidance/Legislation/EHRIncentivePrograms/DataAndReports.html)
      # Documents with root data values other than "PROVIDER CCN" and embedded documents are part of this group
      num_recvd_incentive = Hospital.where("PROVIDER NPI" => {"$ne" => nil})
      puts "num_recvd_incentive = #{num_recvd_incentive.count}"
      num_recvd_incentive_and_have_geo = num_recvd_incentive.where("geo" => {"$ne" => nil})
      puts "  num_recvd_incentive_and_have_geo = #{num_recvd_incentive_and_have_geo.count}"
      num_recvd_incentive_and_have_hcahps = num_recvd_incentive.where("hcahps" => {"$ne" => nil})
      puts "  num_recvd_incentive_and_have_hcahps = #{num_recvd_incentive_and_have_hcahps.count}"
      num_recvd_incentive_and_have_general = num_recvd_incentive.where("general" => {"$ne" => nil})
      puts "  num_recvd_incentive_and_have_general = #{num_recvd_incentive_and_have_general.count}"

      # B) Then we added in HCAHPS data (data.medicare.gov/dataset/Survey-of-Patients-Hospital-Experiences-HCAHPS-/rj76-22dk)

      # C) Then we added in General Hospital data (https://data.medicare.gov/dataset/Hospital-General-Information/v287-28n3)
    end
  end

end
