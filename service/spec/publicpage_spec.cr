require "spec"
require "http/client"
require "faker"
require "./spec_helper"
require "../src/app"

describe "Public page" do
  url = "http://localhost:7331"

  it "получает список всех уязвимостей" do
    resp = HTTP::Client.get(url)
    resp.status_code.should eq 200
    resp.body.should contain("NightCity Exploit Market")
  end

  it "отображает главную страницу с популярными уязвимостями" do
    response = HTTP::Client.get("#{url}/")
    response.status_code.should eq 200
    response.body.should contain("Популярные уязвимости")
    response.body.should contain("NightCity Exploit Market")
  end

  it "отображает страницу /about" do
    response = HTTP::Client.get("#{url}/about")
    response.status_code.should eq 200
    response.body.should contain("О проекте")
  end

  it "отображает страницу /help" do
    response = HTTP::Client.get("#{url}/help")
    response.status_code.should eq 200
    response.body.should contain("Помощь")
  end
end
