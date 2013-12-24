class Hospital
  include Mongoid::Document
  include Mongoid::CachedJson
  include ModelHelpers

  index({ "PROVIDER CCN" => 1})
  index({ "PROVIDER STATE" => 1})
  index({ "PROGRAM YEAR 2011" => 1, "PROGRAM YEAR 2012" => 1, "PROGRAM YEAR 2013" => 1})
  index({ "geo.geometry.location" => "2d"})
  index({ "geo" => 1})
  store_in collection: "ProvidersPaidByEHRProgram_Sept2013_EH"

  embeds_many :hc_hais
  embeds_many :hc_hacs

  json_fields \
    :"PROVIDER CCN" => { }, :id => {:type => :reference, :definiton => :_id}, :incentives_received => {:type => :reference},
    :phone_number => {:type => :reference}, :geo => {},
    :address => {:type => :reference}, :name => {:type => :reference}, :npi => {:type => :reference},
    :cms255210 => {:type => :reference}, :hc_hais => { :type => :reference}, :hc_hacs => { :type => :reference}, :general => {:type => :reference, :definition => :general_or_not}, :hcahps => {:type => :reference, :definition => :hcahps_or_not}, :jc_id => {:type => :reference, :definition => :jc_id_or_not}, :ahrq_m => {:type => :reference, :definition => :ahrq_m_or_not}, :ooc => {:type => :reference, :definition => :ooc_or_not}

  scope :without_hcahps, where("hcahps" => nil)
  scope :with_hcahps, where("hcahps" => {"$ne" => nil})
  scope :with_geo, where("geo" => {"$ne" => nil})
  scope :without_geo, where("geo" => nil)
  scope :with_general, where("general" => {"$ne" => nil})
  scope :without_general, where("general" => nil)
  scope :with_jc_id, where("jc" => {"$ne" => nil})
  scope :without_jc_id, where("jc" => nil)
  scope :with_ahrq_m, where("ahrq_m" => {"$ne" => nil})
  scope :without_ahrq_m, where("ahrq_m" => nil)
  scope :with_ooc, where("ooc" => {"$ne" => nil})
  scope :without_ooc, where("ooc" => nil)
  scope :with_hc_hais, where("hc_hais" => {"$ne" => nil})
  scope :without_hc_hais, where("hc_hais" => nil)
  scope :with_hc_hacs, where("hc_hacs" => {"$ne" => nil})
  scope :without_hc_hacs, where("hc_hacs" => nil)

  scope :received_any_incentives, any_of([{"PROGRAM YEAR 2011" => true},{"PROGRAM YEAR 2012" => true},{"PROGRAM YEAR 2013" => true}])
  scope :never_received_any_incentives, where({"PROGRAM YEAR 2012" => nil, "PROGRAM YEAR 2011" => nil, "PROGRAM YEAR 2013" => nil})

  def self.exclude_from_geojson
    [:hcahps,:hc_hais,:hc_hacs,:ahrq_m,:ooc]
  end

  def keys_to_exclude_from_json
    ["provider_number","address_1","address_2","zip_code","phone_number","state","city","county_name","hospital_name","_source","_updated_at"]
  end

  def hcahps_or_not
    self["hcahps"].present? ? remove_keys(self["hcahps"],keys_to_exclude_from_json) : {}
  end

  def jc_id_or_not
    self["jc"].present? ? self["jc"]["org_id"] : nil
  end

  def general_or_not
    self["general"].present? ? remove_keys(self["general"],keys_to_exclude_from_json) : {}
  end

  def ahrq_m_or_not
    self["ahrq_m"].present? ? remove_keys(self["ahrq_m"],keys_to_exclude_from_json) : []
  end

  def ooc_or_not
    self["ooc"].present? ? remove_keys(self["ooc"],keys_to_exclude_from_json) : []
  end

  def cms255210
    data = {}
    (2010..2013).each do |year|
      key = "CMS255210_#{year}"
      if self[key]
        data[year] = self[key].select{|k,v| !["PROVIDER_NUMBER","HOSPITAL_Name","State","City","County","Street_Addr","Po_BOx","Zip_Code"].include?(k) }
      else
        data[year] = nil
      end
    end
    return data
  end

  # Usage: Hospital.mr_compute_descriptive_stats_excluding_nulls("hcahps.percent_of_patients_who_reported_that_the_area_around_their_room_was_always_quiet_at_night_")
  def self.mr_compute_descriptive_stats_excluding_nulls(field_dot_notation = "hcahps.percent_of_patients_who_reported_that_the_area_around_their_room_was_always_quiet_at_night_")
    # major kudos to https://gist.github.com/RedBeard0531/1886960 for base code
    query = {field_dot_notation => {"$ne" => nil}}
    js_field = "['"+field_dot_notation.gsub(".","']['")+"']"
    scope = "not_null"
    today = Date.today.to_s
    map = %Q{
      function map() {
        emit({field: "#{field_dot_notation}", scope:"all_not_null", on: "#{today}"}, // Or put a GROUP BY key here
             {sum: parseInt(this#{js_field}), // the field you want stats for
              min: parseInt(this#{js_field}),
              max: parseInt(this#{js_field}),
              count:1,
              diff: 0, // M2,n:  sum((val-mean)^2)
        });
      }
    }
    reduce = %Q{
      function reduce(key, values) {
          var a = values[0]; // will reduce into here
          for (var i=1/*!*/; i < values.length; i++){
              var b = values[i]; // will merge 'b' into 'a'

              // temp helpers
              var delta = a.sum/a.count - b.sum/b.count; // a.mean - b.mean
              var weight = (a.count * b.count)/(a.count + b.count);

              // do the reducing
              a.diff += b.diff + delta*delta*weight;
              a.sum += b.sum;
              a.count += b.count;
              a.min = Math.min(a.min, b.min);
              a.max = Math.max(a.max, b.max);
          }
          return a;
      }
    }
    finalize = %Q{
      function finalize(key, value){
          value.avg = value.sum / value.count;
          value.variance = value.diff / value.count;
          value.stddev = Math.sqrt(value.variance);
          return value;
      }
    }
    Hospital.where(query).map_reduce(map, reduce).finalize(finalize).out(merge: DescriptiveStatistic.collection.name).each{|x| puts x}
  end

  def to_geojson(keys_to_exclude = Hospital.exclude_from_geojson, include_full_geo = false)
    hash = self.as_json
    coordinates = [hash[:geo]["geometry"]["location"]["lng"],hash[:geo]["geometry"]["location"]["lat"]]
    keys_to_exclude.each{|k| hash.delete(k) if hash[k]}
    hash.delete(:geo) unless include_full_geo
    {"type" => "Feature", "id" => hash[:id].to_s, "properties" => hash, "geometry" => {"type" => "Point", "coordinates" => coordinates}}
  end
end

class HcHai
  include Mongoid::Document
  embedded_in :hospital
  index({ "measure" => 1})
  index({ "measure" => 1, "score" => -1})
  field :measure
  field :score
  field :footnote
end

class HcHac
  include Mongoid::Document
  embedded_in :hospital
  index({ "measure" => 1})
  index({ "measure" => 1, "rate_per_1_000_discharges_" => -1})
  field :measure
  field :rate_per_1_000_discharges_
end
