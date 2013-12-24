# Initialize PostgreSQL connection (for BloomAPI integration) using ActiveRecord
if settings.bloom_api_db_url

  db = URI.parse(settings.bloom_api_db_url)
  ActiveRecord::Base.establish_connection(
    :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
    :host     => db.host,
    :username => db.user,
    :password => db.password,
    :database => db.path[1..-1],
    :encoding => 'utf8'
  )

  class NPI < ActiveRecord::Base
    self.table_name = 'npis'

    # Collect all NPIs in BloomAPI database into a text file
    def self.file_of_npis(filename = "public/data/list_of_npis_from_bloom_api.txt", limit = 100000)
      received = 0
      total_count = NPI.count
      file = File.open(filename, "w")

      until received == total_count
        npis = self.select(:npi).limit(limit).offset(received).map(&:npi)
        file.write(npis.join("\n")+"\n") 
        received += npis.size
        puts "Received #{received} of #{total_count} (#{(received/total_count.to_f)*100}%)"
      end

      file.close
      puts "Done!"

      return received
    end

  end

end
