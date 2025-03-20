require "db"
require "json"

class Purchase
  include JSON::Serializable
  include DB::Serializable

  property transaction_id : Int32
  property from_user : Int32
  property to_user : Int32
  property amount : Int32
  property transaction_type : String
  property created_at : Time

  property vulnerability_id : Int32
  property cve_code : String
  property title : String
  property vuln_price : Int32
  property vuln_status : String

  def initialize(
    @transaction_id, @from_user, @to_user, @amount, @transaction_type, @created_at,
    @vulnerability_id, @cve_code, @title, @vuln_price, @vuln_status,
  )
  end
end
