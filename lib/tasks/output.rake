task :output_provider_geojson_by_state do
  STATES.each do |state|
    print "Starting #{state} ..."
    filename = "public/data/by_state/provider-#{state}.geojson"
    geojson = Provider.where("PROVIDER STATE" => state).map {|p| to_geojson_point(p)}
    File.open(filename, 'w') { |file| file.write(geojson.to_json) }
    print "... done.\n"
  end
end
