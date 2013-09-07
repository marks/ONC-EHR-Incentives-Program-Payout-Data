namespace :providers do

  task :ensure_fields_are_properly_formatted do
    Provider.all.each do |h|
      h.update_attribute("PROVIDER ZIP 5 CD",add_leading_zeros(h["PROVIDER ZIP 5 CD"],5)) unless h["PROVIDER ZIP 5 CD"].to_s.length == 0
      h.update_attribute("PROVIDER ZIP 4 CD",add_leading_zeros(h["PROVIDER ZIP 4 CD"],4)) unless h["PROVIDER ZIP 4 CD"].to_s.length == 0
    end
  end

  desc "Write state provider GeoJSON files to public/data"
  task :output_provider_geojson_by_state do
    STATES.each do |state|
      filename = "public/data/by_state/provider-#{state}.geojson"
      print "Starting #{state} geojson export to #{filename} "
      geojson = Provider.where("PROVIDER STATE" => state, "geo" => {"$ne" => nil}).map {|p| p.to_geojson}
      File.open(filename, 'w') { |file| file.write(geojson.to_json) }
      print "... done.\n"
    end
  end

end