require "../models/transaction"
require "../helpers/auth_helpers"
require "../helpers/mask_email"

module TransactionsController
  def self.index(env)
    current_user = AuthHelpers.current_user(env)
    unless current_user
      return env.redirect("/?flash=Сначала+войдите&type=warn")
    end
    page = (env.params.query["page"]? || 1).to_i
    limit = 50
    offset = (page - 1) * limit
    history_of_transactions = Transaction.all(limit, offset)
    render "src/views/transactions/index.ecr", "src/views/layout.ecr"
  end

  def self.show(env)
    current_user = AuthHelpers.current_user(env)

    unless current_user
      return env.redirect("/?flash=Сначала+войдите&type=warn")
    end

    transaction_id = env.params.url["id"].to_i
    transaction = Transaction.find(transaction_id)

    if transaction
      if transaction.from_user == current_user.email || transaction.to_user == current_user.email
        render "src/views/transactions/show.ecr", "src/views/layout.ecr"
      else
        env.response.status_code = 403
        render "src/views/notauthorize.ecr", "src/views/layout.ecr"
      end
    else
      env.redirect("/transactions?flash=Транзакция+не+найдена&type=warning")
    end
  end

  def self.transfer(env)
    current_user = AuthHelpers.current_user(env)

    unless current_user
      return env.redirect("/?flash=Сначала+войдите&type=warn")
    end

    sender_email = env.params.body["sender_email"]
    recipient_email = env.params.body["recipient_email"]
    amount = env.params.body["amount"]?.try(&.to_i) || 0

    if amount <= 0
      return env.redirect("/transactions/transfer?flash=Некорректные+данные&type=warn")
    end

    transaction = Transaction.create_transfer(sender_email, recipient_email, amount)

    if transaction.is_a?(Transaction)
      env.redirect("/transactions/#{transaction.id}?flash=Перевод+успешно+создан&type=success")
    else
      env.redirect("/transactions/transfer?flash=Что-то+пошло+не+так&type=danger")
    end
  end
end
