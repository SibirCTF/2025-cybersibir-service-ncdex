require "../models/user"
require "../models/transaction"
require "../models/vulnerability"
require "../helpers/auth_helpers"

module UsersController
  def self.register(env)
    username = env.params.body["username"].to_s
    email = env.params.body["email"].to_s
    password = env.params.body["password"].to_s

    user = User.create(username, email, password)
    if user
      AuthHelpers.login_user(env, user.id)
      env.redirect("/users/profile?flash=Добро+пожаловать+#{URI.encode_www_form(user.username)}&type=success")
    else
      env.redirect("/?flash=Что-то+пошло+не+так&type=danger")
    end
  end

  def self.profile(env)
    current_user = AuthHelpers.current_user(env)

    if current_user
      history_of_transactions = Transaction.get_by_user_with_email(current_user.id)
      purchased_vulnerabilities = Transaction.get_purchases_with_vulnerability(current_user.id)
      own_vulnerabilities = Vulnerability.all_own(current_user.id)

      render "src/views/users/profile.ecr", "src/views/layout.ecr"
    else
      env.redirect("/?flash=Сначала+войдите&type=warn")
    end
  end

  def self.transfer(env)
    current_user = AuthHelpers.current_user(env)

    if current_user
      render "src/views/users/transfer.ecr", "src/views/layout.ecr"
    else
      env.redirect("/?flash=Сначала+войдите&type=warn")
    end
  end

  def self.show(env)
    current_user = AuthHelpers.current_user(env)

    if current_user.nil?
      env.redirect("/?flash=Сначала+войдите&type=warn")
      return
    end

    user_id = env.params.url["id"].to_i
    user = User.find(user_id)

    if user
      render "src/views/users/show.ecr", "src/views/layout.ecr"
    else
      env.redirect("/users/profile?flash=Пользователь+не+найден&type=danger")
    end
  end

  def self.update(env)
    current_user = AuthHelpers.current_user(env)

    if current_user.nil?
      env.redirect("/?flash=Сначала+войдите&type=warn")
      return
    end

    username = env.params.body["username"]? || current_user.username
    email = env.params.body["email"]? || current_user.email

    if current_user.update(username: username, email: email)
      env.redirect("/users/profile?flash=Данные+успешно+обновлены&type=success")
    else
      env.redirect("/users/profile?flash=Не+удалось+обновить+данные&type=danger")
    end
  end
end
