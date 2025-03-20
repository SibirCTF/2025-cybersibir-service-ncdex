require "db"
require "pg"
require "../models/purchase"

class HistoryTransaction
  include JSON::Serializable
  include DB::Serializable

  property id : Int32
  property vulnerability_id : Nil | Int32
  property from_user : String
  property to_user : String
  property amount : Int32
  property transaction_type : String
  property created_at : Time
end
