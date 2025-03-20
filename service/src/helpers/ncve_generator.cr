require "random"

module CVEGenerator
  PREFIXES = ["HACK", "CORP", "NEURO", "NET", "MIL"]

  def self.generate
    year = Random.rand(2070..2080)
    id = Random.rand(10000..99999)
    category = PREFIXES.sample
    "NCVE-#{year}-#{id}-#{category}"
  end

  # Хакерские слова для анализа
  HACKER_TERMS = [
    "0-day", "attack", "backdoor", "bruteforce", "buffer", "bypass", "clickjacking",
    "code", "command", "cryptojacking", "csrf", "ddos", "deserialization", "dos",
    "escalation", "exploit", "injection", "mitm", "overflow", "payload",
    "phishing", "privilege", "rce", "rootkit", "sniffing", "sql", "ssrf", "xss", "xxe",
  ]

  # Оценка severity
  def self.calculate_severity(title : String, description : String) : Tuple(String, String)
    # Количество слов в заголовке и описании
    title_word_count = title.split(/\s+/).size
    description_word_count = description.split(/\s+/).size

    # Проверяем наличие хакерских терминов в title и description
    title_has_hack_word = HACKER_TERMS.any? { |term| title.downcase.includes?(term) }
    description_hack_count = HACKER_TERMS.count { |term| description.downcase.includes?(term) }

    # Повышаем счетчик, если в title есть хакерские термины
    hack_count = description_hack_count + (title_has_hack_word ? 2 : 0)

    # Если в title или description слишком мало слов — понижаем серьезность
    if title_word_count < 3 || description_word_count < 10
      hack_count = [hack_count - 1, 0].max
    end

    # Определяем severity
    severity =
      case hack_count
      when 0    then "none"
      when 1..3 then "low"
      when 4..6 then "medium"
      when 7..8 then "high"
      else           "critical"
      end

    # Если нет хакерских терминов, отправляем на ручную проверку
    status = hack_count > 0 ? "available" : "manual_review"

    {status, severity}
  end
end
