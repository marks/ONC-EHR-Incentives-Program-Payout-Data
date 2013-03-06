namespace :output do

  desc "Write state provider GeoJSON files to public/data"
  task :output_provider_geojson_by_state do
    STATES.each do |state|
      filename = "public/data/by_state/provider-#{state}.geojson"
      print "Starting #{state} geojson export to #{filename} "
      geojson = Provider.where("PROVIDER STATE" => state, "geo" => {"$ne" => nil}).map {|p| to_geojson_point(p)}
      File.open(filename, 'w') { |file| file.write(geojson.to_json) }
      print "... done.\n"
    end
  end

  desc "Write state provider GeoJSON files to public/data"
  task :output_hospital_geojson do
    filename = "public/data/ProvidersPaidByEHRProgram_Dec2012_HOSP_FINAL.geojson"
    print "Starting hospital geojson export to #{filename} "
    geojson = Hash.new
    geojson["type"] = "FeatureCollection"
    geojson["features"] = Hospital.where("geo" => {"$ne" => nil}).map {|h| to_geojson_point(h,["geo","hcahps"])}
    File.open(filename, 'w') { |file| file.write(geojson.to_json) }
    print "... done.\n"
  end


end
