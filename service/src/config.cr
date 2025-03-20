require "yaml"

struct Config
  include YAML::Serializable

  property port : Int32
  property name : String
  property database : String
end
