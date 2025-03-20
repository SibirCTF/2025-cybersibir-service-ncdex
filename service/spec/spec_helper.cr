require "faker"
require "http/client"
require "uri"

class Helper
  URL = "http://localhost:7331"

  def self.create_test_user_and_session
    form_data = URI::Params.encode({
      "username" => Faker::Name.name,
      "email"    => Faker::Internet.email,
      "password" => Faker::Internet.password,
    })
    headers = HTTP::Headers{
      "Content-Type"   => "application/x-www-form-urlencoded",
      "Content-Length" => form_data.bytesize.to_s,
    }
    response = HTTP::Client.post("#{URL}/users/register", headers: headers, body: form_data)
    HTTP::Cookies.from_server_headers(response.headers)
  end
end
