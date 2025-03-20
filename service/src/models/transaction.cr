require "db"
require "pg"
require "../models/purchase"
require "../models/history_transaction"

class Transaction
  include JSON::Serializable
  include DB::Serializable

  property id : Int32
  property from_user : Int32
  property to_user : Int32
  property amount : Int32
  property transaction_type : String
  property created_at : Time

  def initialize(@id, @from_user, @to_user, @amount, @transaction_type, @created_at)
  end

  def self.get_by_user(user_id : Int32)
    query = <<-SQL
      SELECT id, from_user, to_user, amount, transaction_type, created_at
      FROM transactions
      WHERE from_user = $1 OR to_user = $1
      ORDER BY created_at DESC
    SQL

    transactions = [] of Transaction
    DBC.query(query, user_id) do |rs|
      transactions = Transaction.from_rs(rs)
    end
    transactions
  end

  def self.get_by_user_with_email(user_id : Int32)
    query = <<-SQL
      SELECT
        t.id,
        t.vulnerability_id,
        u1.email AS from_user,
        u2.email AS to_user,
        t.amount,
        t.transaction_type,
        t.created_at
      FROM transactions t
      LEFT JOIN users u1 ON t.from_user = u1.id
      LEFT JOIN users u2 ON t.to_user = u2.id
      WHERE t.from_user = $1 OR t.to_user = $1
      ORDER BY t.created_at DESC
    SQL

    history_transactions = [] of HistoryTransaction
    DBC.query(query, user_id) do |rs|
      history_transactions = HistoryTransaction.from_rs(rs)
    end
    history_transactions
  end

  def self.all(limit : Int32, offset : Int32)
    query = <<-SQL
      SELECT
        t.id,
        t.vulnerability_id,
        u1.email AS from_user,
        u2.email AS to_user,
        t.amount,
        t.transaction_type,
        t.created_at
      FROM transactions t
      LEFT JOIN users u1 ON t.from_user = u1.id
      LEFT JOIN users u2 ON t.to_user = u2.id
      ORDER BY t.created_at DESC
      LIMIT $1 OFFSET $2
    SQL

    history_transactions = [] of HistoryTransaction
    DBC.query(query, limit, offset) do |rs|
      history_transactions = HistoryTransaction.from_rs(rs)
    end
    history_transactions
  end

  def self.get_purchases_with_vulnerability(user_id : Int32)
    query = <<-SQL
      SELECT
        t.id as transaction_id,
        t.from_user,
        t.to_user,
        t.amount,
        t.transaction_type,
        t.created_at,
        v.id as vulnerability_id,
        v.cve_code,
        v.title,
        v.price as vuln_price,
        v.status as vuln_status
      FROM transactions t
      JOIN vulnerabilities v ON v.id = t.vulnerability_id
      WHERE t.transaction_type = 'purchase' AND t.from_user = $1
      ORDER BY t.created_at DESC LIMIT 100
    SQL

    purchases = [] of Purchase
    DBC.query(query, user_id) do |rs|
      purchases = Purchase.from_rs(rs)
    end
    purchases
  end

  def self.get_sales(user_id : Int32)
    query = <<-SQL
      SELECT id, from_user, to_user, amount, transaction_type, created_at
      FROM transactions
      WHERE transaction_type = 'purchase' AND from_user = $1
      ORDER BY created_at DESC
    SQL

    sales = [] of Transaction
    DBC.query(query, user_id) do |rs|
      sales = Transaction.from_rs(rs)
    end
    sales
  end

  def self.find(transaction_id : Int32)
    query = <<-SQL
      SELECT
        t.id,
        t.vulnerability_id,
        u1.email AS from_user,
        u2.email AS to_user,
        t.amount,
        t.transaction_type,
        t.created_at
      FROM transactions t
      LEFT JOIN users u1 ON t.from_user = u1.id
      LEFT JOIN users u2 ON t.to_user = u2.id
      WHERE t.id = $1 LIMIT 1
    SQL

    HistoryTransaction.from_rs(DBC.query(query, transaction_id)).first?
  end

  def self.create_transfer(from_email : String, to_email : String, amount : Int32)
    sender_query = "SELECT id, balance FROM users WHERE email = $1"
    sender = DBC.query_one?(sender_query, from_email) do |rs|
      {rs.read(Int32), rs.read(Int32)}
    end

    return nil if ExchangeAccount.instance.email == from_email # аккаунт биржи не может делать переводы, только бонусы
    return nil unless sender

    sender_id, sender_balance = sender

    if sender_balance < amount
      Log.info { "Перевод отклонён - Недостаточно средств: from_user: #{from_email}, to_user: #{to_email}" }
      return nil
    end

    recipient_query = "SELECT id FROM users WHERE email = $1"
    recipient_id = DBC.query_one?(recipient_query, to_email, &.read(Int32))

    return nil unless recipient_id

    update_from = "UPDATE users SET balance = balance - $1 WHERE id = $2"
    DBC.exec(update_from, amount, sender_id)

    update_to = "UPDATE users SET balance = balance + $1 WHERE id = $2"
    DBC.exec(update_to, amount, recipient_id)

    insert_query = <<-SQL
      INSERT INTO transactions (from_user, to_user, amount, transaction_type, created_at)
      VALUES ($1, $2, $3, 'transfer', now())
      RETURNING id, from_user, to_user, amount, transaction_type, created_at
    SQL

    DBC.query_one(insert_query, sender_id, recipient_id, amount) do |rs|
      Transaction.new(
        rs.read(Int32),
        rs.read(Int32),
        rs.read(Int32),
        rs.read(Int32),
        rs.read(String),
        rs.read(Time)
      )
    end
  end
end
