require "spec"
require "http/client"
require "faker"
require "./spec_helper"
require "../src/app"

describe "Vulnerabilities API (HTML-oriented)" do
  url = "http://localhost:7331"

  it "создает новую уязвимость" do
    cookies = Helper.create_test_user_and_session
    title = Faker::Company.name
    form_data = URI::Params.encode({
      "title"       => title,
      "description" => Faker::Hacker.say_something_smart,
      "price"       => "500",
    })
    headers = HTTP::Headers{
      "Content-Type"   => "application/x-www-form-urlencoded",
      "Content-Length" => form_data.bytesize.to_s,

    }
    cookies.add_request_headers(headers)

    response = HTTP::Client.post("#{url}/vulnerabilities", headers: headers, body: form_data)
    response.status_code.should eq 302
    response.headers["Location"].should match(/\/vulnerabilities\/\d+\?flash=Уязвимость\+успешно\+создана/)
    # response.body.should contain(title) - fixme нужно перейти по редиректу
  end

  it "получает список всех уязвимостей" do
    cookies = Helper.create_test_user_and_session
    headers = HTTP::Headers.new
    cookies.add_request_headers(headers)

    resp = HTTP::Client.get("#{url}/vulnerabilities", headers: headers)
    resp.status_code.should eq 200
    resp.body.should contain("Список уязвимостей")
  end
end
