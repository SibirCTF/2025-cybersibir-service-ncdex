require "../models/vulnerability"
require "../helpers/ncve_generator"
require "../helpers/auth_helpers"
require "../helpers/vuln_mappings"

module VulnerabilitiesController
  def self.home(env)
    current_user = AuthHelpers.current_user(env)

    popular_vulnerabilities = Vulnerability.all_popular
    render "src/views/home.ecr", "src/views/layout.ecr"
  end

  def self.index(env)
    current_user = AuthHelpers.current_user(env)
    return env.redirect("/?flash=Сначала+войдите&type=warn") unless current_user

    page = env.params.query["page"]?.try(&.to_i?) || 1
    per_page = 9

    # фильтры из параметров
    filters = {
      "exploit_type" => env.params.query["exploit_type"]?,
      "platform"     => env.params.query["platform"]?,
      "severity"     => env.params.query["severity"]?,
      "status"       => env.params.query["status"]?,
      "search"       => env.params.query["search"]?,
    }

    vulnerabilities, has_more = Vulnerability.paginated(page, per_page, filters)

    render "src/views/vulnerabilities/index.ecr", "src/views/layout.ecr"
  end

  def self.show(env)
    current_user = AuthHelpers.current_user(env)
    vulnerability_id = env.params.url["id"].to_i
    vulnerability = Vulnerability.find(vulnerability_id)

    if vulnerability
      if current_user && current_user.can_view_vulnerability(vulnerability.id)
        render "src/views/vulnerabilities/show.ecr", "src/views/layout.ecr"
      else
        render "src/views/vulnerabilities/show_short.ecr", "src/views/layout.ecr"
      end
    else
      env.redirect("/vulnerabilities?flash=Уязвимость+не+найдена&type=warn")
    end
  end

  def self.create(env)
    current_user = AuthHelpers.current_user(env)

    unless current_user
      return env.redirect("/?flash=Сначала+войдите&type=warn")
    end

    title = env.params.body["title"]?.to_s
    description = env.params.body["description"]?.to_s
    exploit = env.params.body["exploit"]?.to_s
    exploit_type = env.params.body["exploit_type"]?.to_s
    platform = env.params.body["platform"]?.to_s
    price = env.params.body["price"]?.try(&.to_i) || 0

    if title.empty? || description.empty? || price <= 0
      return env.redirect("/vulnerabilities/new?flash=Некорректные+данные&type=warn")
    end

    vulnerability = Vulnerability.create(
      current_user.id,
      title,
      description,
      exploit,
      exploit_type,
      platform,
      price,
    )

    if vulnerability
      env.redirect("/vulnerabilities/#{vulnerability.id}?flash=Уязвимость+успешно+добавлена&type=success")
    else
      env.redirect("/vulnerabilities/new?flash=Что-то+пошло+не+так&type=danger")
    end
  end

  def self.update(env)
    current_user = AuthHelpers.current_user(env)

    unless current_user
      return env.redirect("/?flash=Сначала+войдите&type=warn")
    end

    vuln_id = env.params.url["id"].to_i
    vulnerability = Vulnerability.find(vuln_id)

    if vulnerability.nil?
      return env.redirect("/vulnerabilities?flash=Уязвимость+не+найдена&type=warn")
    end

    title = env.params.body["title"]? || vulnerability.title
    description = env.params.body["description"]? || vulnerability.description
    exploit = env.params.body["exploit"]? || vulnerability.exploit
    exploit_type = env.params.body["exploit_type"]? || vulnerability.exploit_type
    platform = env.params.body["platform"]? || vulnerability.platform
    price = env.params.body["price"]?.try(&.to_i) || vulnerability.price
    status = env.params.body["status"]? || vulnerability.status

    if vulnerability.update(title: title, description: description, exploit: exploit, exploit_type: exploit_type, platform: platform, price: price, status: status)
      env.redirect("/vulnerabilities/#{vulnerability.id}?flash=Данные+уязвимости+обновлены&type=success")
    else
      env.redirect("/vulnerabilities/#{vulnerability.id}/edit?flash=Не+удалось+обновить&type=danger")
    end
  end

  def self.buy(env)
    current_user = AuthHelpers.current_user(env)

    unless current_user
      return env.redirect("/?flash=Сначала+войдите&type=warn")
    end

    vuln_id = env.params.url["id"].to_i
    vulnerability = Vulnerability.find(vuln_id)

    if vulnerability.nil?
      return env.redirect("/vulnerabilities?flash=Уязвимость+не+найдена&type=warn")
    end

    transaction_id = vulnerability.buy(current_user.id)

    if transaction_id
      env.redirect("/vulnerabilities/#{vuln_id}?flash=Уязвимость+успешно+куплена&type=success")
    else
      env.redirect("/vulnerabilities/#{vuln_id}?flash=Не+удалось+купить+уязвимость&type=danger")
    end
  end
end
