class DBConnect
  def self.wait_for_db(dsn : String, max_retries = 10, delay_seconds = 1)
    retries = 0

    loop do
      begin
        db = DB.open(dsn)
        Log.info { "Подключение к базе данных успешно" }
        return db
      rescue ex
        retries += 1
        if retries >= max_retries
          Log.warn { "Не удалось подключиться к базе данных после #{retries} попыток" }
          raise ex
        else
          Log.info { "Попытка #{retries}: БД недоступна, повтор через #{delay_seconds}s..." }
          sleep Time::Span.new(seconds: delay_seconds)
        end
      end
    end
  end
end
