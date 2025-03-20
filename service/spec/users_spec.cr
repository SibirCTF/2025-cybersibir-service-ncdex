require "spec"
require "http/client"
require "faker"
require "uri"
require "../src/app"

Spec.before_each do
  # Очистка тестовой базы перед каждым тестом
  # DBC.exec("TRUNCATE users RESTART IDENTITY CASCADE")
end

describe "Users API (form-data, redirect with flash)" do
  url = "http://localhost:7331"

  it "создает нового пользователя" do
    username = Faker::Name.name
    email = Faker::Internet.email
    password = Faker::Internet.password

    form_data = URI::Params.encode({
      "username" => username,
      "email"    => email,
      "password" => password,
    })

    headers = HTTP::Headers{
      "Content-Type" => "application/x-www-form-urlencoded",
    }

    response = HTTP::Client.post("#{url}/users/register", headers: headers, body: form_data)

    # Проверяем redirect и flash-сообщение
    response.status_code.should eq 302
    location = response.headers["Location"]
    location.should contain("/users/profile")
    location.should contain("flash=Добро+пожаловать")
    location.should contain(URI.encode_www_form(username))
  end

  it "логинит пользователя" do
    username = Faker::Name.name
    email = Faker::Internet.email
    password = Faker::Internet.password

    # Создаем пользователя
    form_register = URI::Params.encode({
      "username" => username,
      "email"    => email,
      "password" => password,
    })

    headers = HTTP::Headers{
      "Content-Type" => "application/x-www-form-urlencoded",
    }

    HTTP::Client.post("#{url}/users/register", headers: headers, body: form_register)

    # Пытаемся войти
    form_login = URI::Params.encode({
      "email"    => email,
      "password" => password,
    })

    response = HTTP::Client.post("#{url}/users/login", headers: headers, body: form_login)

    # Проверяем redirect и flash-сообщение
    response.status_code.should eq 302
    location = response.headers["Location"]
    location.should contain("Приветствую")
  end

  it "получает страницу профиля пользователя" do
    username = Faker::Name.name
    email = Faker::Internet.email
    password = Faker::Internet.password

    form_register = URI::Params.encode({
      "username" => username,
      "email"    => email,
      "password" => password,
    })

    headers = HTTP::Headers{
      "Content-Type"   => "application/x-www-form-urlencoded",
      "Content-Length" => form_register.bytesize.to_s,
    }

    register_response = HTTP::Client.post("#{url}/users/register", headers: headers, body: form_register)

    cookies = HTTP::Cookies.from_server_headers(register_response.headers)
    headers_with_cookies = HTTP::Headers.new
    cookies.add_request_headers(headers_with_cookies)

    # Явно следуем редиректу после регистрации
    location = register_response.headers["Location"]
    redirect_response = HTTP::Client.get("#{url}#{location}", headers: headers_with_cookies)

    # Теперь пытаемся получить страницу профиля
    response = HTTP::Client.get("#{url}/users/profile", headers: headers_with_cookies)

    response.status_code.should eq 200
    response.body.should contain(username)
    response.body.should contain("Профиль пользователя")
  end
end
