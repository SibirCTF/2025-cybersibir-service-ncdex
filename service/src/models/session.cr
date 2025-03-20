require "db"
require "pg"
require "json"

module Session
  extend self

  def get(session_id : String) : Hash(String, JSON::Any)
    query = "SELECT data FROM sessions WHERE session_id = $1"
    json = DBC.query_one?(query, session_id, &.read(String))

    if json
      Hash(String, JSON::Any).from_json(json)
    else
      {} of String => JSON::Any
    end
  end

  def set(session_id : String, data : Hash(String, JSON::Any))
    json_data = data.to_json

    query = <<-SQL
      INSERT INTO sessions (session_id, data, updated_at)
      VALUES ($1, $2, now())
      ON CONFLICT (session_id)
      DO UPDATE SET data = EXCLUDED.data, updated_at = now()
    SQL

    DBC.exec(query, session_id, json_data)
  end

  def destroy(session_id : String)
    query = "DELETE FROM sessions WHERE session_id = $1"
    DBC.exec(query, session_id)
  end
end
