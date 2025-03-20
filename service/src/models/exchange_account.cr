class ExchangeAccount
  property id : Int32
  property username : String
  property email : String
  property balance : Int32
  property created_at : Time

  def initialize(@id, @username, @email, @balance, @created_at)
  end

  def self.instance : ExchangeAccount
    query = "SELECT id, username, email, balance, created_at FROM users WHERE email = 'exchange@ncem.com' LIMIT 1"
    result = DBC.query_one(query) do |rs|
      ExchangeAccount.new(
        id: rs.read(Int32),
        username: rs.read(String),
        email: rs.read(String),
        balance: rs.read(Int32),
        created_at: rs.read(Time)
      )
    end
    result.not_nil!
  end

  def update_balance!(amount : Int32)
    query = "UPDATE users SET balance = balance + $1 WHERE id = $2"
    DBC.exec(query, amount, id)
    @balance += amount
  end
end
