class DescriptiveStatistic
  include Mongoid::Document
  index({ "_id" => 1},{ unique: true, name: "_id_index" })
  index({ "_id.field" => 1, "_id.on" => -1})
  store_in collection: "descriptive_stats"
end
