require "json"
require "../models/session"

module AuthHelpers
  SESSION_COOKIE_NAME = "ncx_session"

  def self.get_session_id(env) : String?
    cookie = env.request.cookies[SESSION_COOKIE_NAME]?
    cookie.try(&.value)
  end

  def self.current_session(env) : Hash(String, JSON::Any)?
    session_id = get_session_id(env)
    return nil unless session_id

    data = Session.get(session_id)
    data
  rescue ex : Exception
    nil
  end

  def self.current_user(env) : User?
    session = current_session(env)
    if session && (user_id = session["user_id"]?.try(&.as_i?))
      User.find(user_id)
    else
      nil
    end
  end

  def self.login_user(env, user_id : Int32)
    session_id = get_session_id(env) || Random::Secure.hex(16)

    env.response.cookies << HTTP::Cookie.new(
      SESSION_COOKIE_NAME,
      session_id,
      http_only: true,
      path: "/",
      expires: Time.utc + 7.days
    )

    session_data = {"user_id" => JSON::Any.new(user_id)}
    Session.set(session_id, session_data)
  end

  def self.logout(env)
    session_id = get_session_id(env)
    if session_id
      Session.destroy(session_id)
      env.response.cookies << HTTP::Cookie.new(
        SESSION_COOKIE_NAME,
        "",
        expires: Time.utc - 1.day,
        path: "/",
        http_only: true
      )
    end
  end
end
