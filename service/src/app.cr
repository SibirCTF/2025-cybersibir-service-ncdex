require "kemal"
require "kemal-session"

require "yaml"
require "db"
require "pg"

require "./config"
require "./routes"
require "./helpers/dbconnect"

unless File.exists?("./config/config.yml")
  Log.warn { "Конфигурационный файл не найден: './config/config.yml'" }
  exit 1
end

CONFIG = Config.from_yaml(File.read("./config/config.yml"))

# Инициализируем подключение к базе данных
DBC = DBConnect.wait_for_db(CONFIG.database)

Kemal::Session.config.cookie_name = "ncx_session"
Kemal::Session.config.secret = "super_secret_key_2077"

Kemal.config.powered_by_header = false
Kemal.config.port = CONFIG.port
Kemal.config.app_name = CONFIG.name
before_all do |env|
  env.response.content_type = "text/html; charset=utf-8"
end

if Kemal.config.env == "testing" # Костыль что бы тесты запускались
  spawn do
    Kemal.run
  end
else
  Kemal.run
end
