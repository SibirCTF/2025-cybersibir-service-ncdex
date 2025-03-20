require "db"
require "pg"
require "./exchange_account"
require "../helpers/bonus"

class User
  include JSON::Serializable
  include DB::Serializable

  property id : Int32
  property username : String
  property email : String
  property balance : Int32
  property created_at : Time

  def initialize(@id, @username, @email, @balance, @created_at)
  end

  def self.create(username, email, password)
    query = <<-SQL
      INSERT INTO users (username, email, password_hash, balance, created_at)
      VALUES ($1, $2, crypt($3, gen_salt('bf')), 0, now())
      RETURNING id, username, email, balance, created_at
    SQL

    user = User.from_rs(DBC.query(query, username, email, password)).first

    if user
      exchange_account = ExchangeAccount.instance
      exchange_balance = exchange_account.balance
      bonus = Bonus.welcome_from_exchange(exchange_balance)

      if bonus > 0
        exchange_account.update_balance!(-bonus)

        bonus_query = <<-SQL
          INSERT INTO transactions (from_user, to_user, amount, transaction_type, created_at)
          VALUES ($1, $2, $3, 'bonus', now())
        SQL
        DBC.exec(bonus_query, exchange_account.id, user.id, bonus)

        update_user_balance = "UPDATE users SET balance = balance + $1 WHERE id = $2"
        DBC.exec(update_user_balance, bonus, user.id)

        user.balance += bonus
      end
    end

    user
  end

  def self.authenticate(email, password)
    query = "SELECT id, username, email, balance, created_at FROM users WHERE email = $1 AND password_hash = crypt($2, password_hash)"
    result = DBC.query(query, email, password)

    u = User.from_rs(result)
    if u.size > 0
      u.first
    else
      nil
    end
  end

  def self.find(user_id)
    query = "SELECT id, username, email, balance, created_at FROM users WHERE id = $1"
    result = DBC.query(query, user_id)

    u = User.from_rs(result)
    if u.size > 0
      u.first
    else
      nil
    end
  end

  def update(username : String? = nil, email : String? = nil)
    self.email = email || self.email
    self.username = username || self.username

    query = "UPDATE users SET username = $1, email = $2 WHERE id = $3"
    result = DBC.query(query, self.username, self.email, self.id) # query faster than exec but there is a nuance

    result.rows_affected > 0
  end

  def activity
    query = "SELECT count(*) from transactions where from_user = $1 or to_user = $1"
    DBC.query_one?(query, id, &.read(Int64)) || 0
  end

  def can_view_vulnerability(vulnerability_id : Int32) : Bool
    query = <<-SQL
    SELECT EXISTS (
      SELECT 1 FROM vulnerabilities
      WHERE seller_id = $1 AND id = $2

      UNION

      SELECT 1 FROM transactions
      WHERE from_user = $1 AND vulnerability_id = $2 AND transaction_type = 'purchase'
    )
  SQL

    DBC.query_one(query, id, vulnerability_id, &.read(Bool))
  end

  def mask_email : String
    parts = email.split("@")
    return email if parts.size != 2

    local, domain = parts
    return email if local.size < 3

    masked_local = local[0..2] + ("*" * (local.size - 3))
    "#{masked_local}@#{domain}"
  end
end
