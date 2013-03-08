Mongoid.load!("config/mongoid.yml")

class Hospital
  include Mongoid::Document
  index({ "PROVIDER CCN" => 1},{ unique: true, name: "PROVIDER_CCN_index" })
  index({ "PROVIDER NPI" => 1},{ unique: true, name: "PROVIDER_NPI_index" })
  index({ "PROVIDER STATE" => 1})
  index({ "geo.data.geometry.location" => "2d"})
  store_in collection: "ProvidersPaidByEHRProgram_Dec2012_HOSP_FINAL"

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

end

class Provider
  include Mongoid::Document
  index({ "PROVIDER NPI" => 1},{ unique: true, name: "PROVIDER_NPI_index" })
  index({ "PROVIDER STATE" => 1})
  index({ "geo.data.geometry.location" => "2d"})
  store_in collection: "ProvidersPaidByEHRProgram_Dec2012_EP_FINAL"
end

class DescriptiveStatistic
  include Mongoid::Document
  index({ "_id" => 1},{ unique: true, name: "_id_index" })
  index({ "_id.field" => 1, "_id.on" => -1})
  store_in collection: "descriptive_stats"
end

STATES = ["Alabama",  "Alaska", "Arizona",  "Arkansas", "California", "Colorado", "Connecticut",  "Delaware", "District Of Columbia", "Federated States Of Micronesia", "Florida",  "Georgia",  "Guam", "Hawaii", "Idaho",  "Illinois", "Indiana",  "Iowa", "Kansas", "Kentucky", "Louisiana",  "Maine",  "Marshall Islands", "Maryland", "Massachusetts",  "Michigan", "Minnesota",  "Mississippi",  "Missouri", "Montana",  "Nebraska", "Nevada", "New Hampshire",  "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Palau",  "Pennsylvania", "Puerto Rico",  "Rhode Island", "South Carolina", "South Dakota", "Tennessee",  "Texas",  "Utah", "Vermont","Virginia", "Washington", "West Virginia",  "Wisconsin",  "Wyoming"]

# // find average of a given embedded field; missing values do not count
# db.ProvidersPaidByEHRProgram_Dec2012_HOSP_FINAL.group(
#    { cond: {"hcahps": {"$ne":null}}
#    , initial: {count_not_null: 0, count_null: 0, sum:0}
#    , reduce: function(doc, out){
#       x = doc.hcahps["percent_of_patients_who_reported_that_the_area_around_their_room_was_always_quiet_at_night_"];
#       if(x){out.count_not_null++; out.sum += parseInt(x);}
#       else{out.count_null++;}
#      }
#    , finalize: function(out){ out.avg = out.sum / out.count_not_null }
# } );
