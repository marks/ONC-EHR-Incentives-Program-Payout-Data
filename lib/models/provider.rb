    # { $group : {
    #     _id : "$author",
    #     docsPerAuthor : { $sum : 1 },
    #     viewsPerAuthor : { $sum : "$pageViews" }
    # }}


class Provider
  include Mongoid::Document
  include Mongoid::CachedJson
  include ModelHelpers 
  
  index({ "PROVIDER NPI" => 1},{ unique: true, name: "PROVIDER_NPI_index" })
  index({ "PROVIDER STATE" => 1})
  index({ "PROVIDER STATE" => 1})
  index({ "PROGRAM YEAR 2011" => 1, "PROGRAM YEAR 2012" => 1, "PROGRAM YEAR 2013" => 1})
  index({ "geo.geometry.location" => "2d"})
  index({ "geo" => 1})
  index({ "bloom.practice_address.state" => 1})
  index({ "bloom.business_address.state" => 1})
  store_in collection: "ProvidersPaidByEHRProgram_Sept2013_EP"

  scope :with_geo, where("geo" => {"$ne" => nil})
  scope :without_geo, where("geo" => nil)
  scope :received_any_incentives, any_of([{"PROGRAM YEAR 2011" => true},{"PROGRAM YEAR 2012" => true},{"PROGRAM YEAR 2013" => true}])
  scope :never_received_any_incentives, where({"PROGRAM YEAR 2012" => nil, "PROGRAM YEAR 2011" => nil, "PROGRAM YEAR 2013" => nil})

  # bloom api scopes
  scope :with_bloom, where("bloom" => {"$ne" => nil})
  scope :without_bloom, where("bloom" => nil)
  scope :has_business_address_state, where("bloom.business_address.state" => {"$ne" => nil})  
  scope :has_practice_address_state, where("bloom.business_address.state" => {"$ne" => nil})  

  json_fields \
    :id => {:type => :reference, :definiton => :_id}, :incentives_received => {:type => :reference},
    :geo => {}, :phone_number => {:type => :reference},
    :address => {:type => :reference}, :name => {:type => :reference}, :npi => {:type => :reference}

  def to_geojson(keys_to_exclude = [:geo])
    hash = self.as_json.to_hash
    coordinates = [hash[:geo]["geometry"]["location"]["lng"],hash[:geo]["geometry"]["location"]["lat"]]
    keys_to_exclude.each{|k| hash.delete(k)}
    {"type" => "Feature", "id" => hash[:id].to_s, "properties" => hash, "geometry" => {"type" => "Point", "coordinates" => coordinates}}
  end

  def self.count_of_distinct_values(field)
    self.collection.aggregate(
      {'$group' => {
        '_id' => field,
        'count' => { '$sum' => 1 } }
      }
    ) 
  end


end
