require "kemal"
require "../models/user"
require "../helpers/auth_helpers"

module AuthController
  def self.login(env)
    email = env.params.body["email"]?.to_s
    password = env.params.body["password"]?.to_s

    if email.empty? || password.empty?
      return env.redirect("#{env.request.path}?flash=Введите+email+и+пароль&type=warn")
    end

    user = User.authenticate(email, password)

    if user
      AuthHelpers.login_user(env, user.id)
      env.redirect("/?flash=Приветствую+#{URI.encode_www_form(user.username)}&type=success")
    else
      env.redirect("#{env.request.path}?flash=Неверные+данные+для+входа&type=warn")
    end
  end

  # Логаут
  def self.logout(env)
    if AuthHelpers.current_user(env)
      AuthHelpers.logout(env)
      env.redirect("/?flash=Вы+вышли+из+системы&type=success")
    else
      env.redirect("/?flash=Вы+не+были+авторизованы&type=warn")
    end
  end
end
