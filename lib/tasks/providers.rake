namespace :providers do

  task :ensure_fields_are_properly_formatted do
    Provider.all.each do |h|
      h.update_attribute("PROVIDER ZIP 5 CD",add_leading_zeros(h["PROVIDER ZIP 5 CD"],5)) unless h["PROVIDER ZIP 5 CD"].to_s.length == 0
      h.update_attribute("PROVIDER ZIP 4 CD",add_leading_zeros(h["PROVIDER ZIP 4 CD"],4)) unless h["PROVIDER ZIP 4 CD"].to_s.length == 0
    end
  end

  desc "Write state provider GeoJSON files to public/data"
  task :output_provider_geojson_by_state do
    settings.states.each do |state|
      filename = "public/data/ProvidersPaidByEHRProgram_Sep2013_EP/geojson/#{state}.geojson"
      print "Starting #{state} geojson export to #{filename} "
      geojson = Provider.where("PROVIDER STATE" => state, "geo" => {"$ne" => nil}).map {|p| p.to_geojson}
      File.open(filename, 'w') { |file| file.write(geojson.to_json) }
      print "... done.\n"
    end
  end

  task :ingest_latest_payments_csv do
    CSV.foreach("public/data/ProvidersPaidByEHRProgram_Sep2013_EP/EP_ProvidersPaidByEHRProgram_Sep2013_FINAL-utf8.csv",:headers => true) do |row|
      next if row["PROGRAM YEAR"] == ""
      row["PROVIDER NPI"] = row["PROVIDER NPI"].to_i
      p = Provider.find_or_create_by(:"PROVIDER NPI" => row["PROVIDER NPI"] )
      attrs = row.to_hash

      year = attrs["PROGRAM YEAR"]
      attrs["PROGRAM YEAR #{year}"] = row["PROGRAM YEAR"] == "#{year}"
      attrs["PROGRAM YEAR #{year} CALC PAYMENT"] = row["CALC PAYMENT  AMT ($)"].to_s.gsub("$","")
      attrs.delete("PROGRAM YEAR")
      attrs.delete("CALC PAYMENT  AMT ($)")

      p.update_attributes!(attrs)
      puts "Updated/inserted NPI=#{p["PROVIDER NPI"]}"
    end
  end

  task :ingest_all_individual_providers_from_bloom_api do
    if settings.bloom_api_db_url && settings.bloom_api_base_url 
      filename = "public/data/list_of_npis_from_bloom_api.txt"
      puts "Running: NPI.file_of_npis => #{filename}"
      NPI.file_of_npis(filename)
      count = 1;
      CSV.foreach(filename) do |row|
        npi = row[0].to_i
        puts "Processing #{count} [NPI=#{npi}]"
        bloom_data = JSON.parse(RestClient.get("#{settings.bloom_api_base_url}/api/npis/#{npi}"))
        if bloom_data["result"]["type"] == "individual"
          provider = Provider.find_or_create_by("PROVIDER NPI" => npi)
          bloom_data["result"]["_fetched_at"] = Time.now
          provider.update_attributes!(:bloom => bloom_data["result"])
        end
      count += 1
      end
    else
      puts "!! Cannot run this rake task with `bloom_api_db_url` and `bloom_api_base_url` not set in config/app.yml"
    end
  end

    desc "Print simple report"
  task :simple_report do
    puts "\nWe started by analyzing EPs that received incentive payments in program year 2011, 2012, or 2013. We then added all EPs in the NPPES NPI data set powered by http://bloomapi.com\n\n"
    # Hospitals that DID receive incentive payments
    puts "  # received an incentive* (* in any of 2011, 2012, _or_ 2013) = #{Provider.received_any_incentives.count}"
    puts "    # received an incentive* and we were able to geocode = #{Provider.received_any_incentives.with_geo.count}"
    puts "    # received an incentive* and we found NPPES/BloomAPI data = #{Provider.received_any_incentives.with_bloom.count}"
    # Hospitals that DID NOT receive incentives
    puts "  # did not received an incentive*  = #{Provider.never_received_any_incentives.count}"
    puts "    # did not received an incentive* and we were able to geocode = #{Provider.never_received_any_incentives.with_geo.count}"
    puts "    # did not received an incentive* and we found NPPES/BloomAPI data = #{Provider.never_received_any_incentives.with_bloom.count}"

    puts "TOTAL PROVIDERS IN DB = #{Provider.count} (# received any incentives* + # never received an incentive)\n\n"

  end


end