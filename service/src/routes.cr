require "./models/user"
require "./models/vulnerability"
require "./controllers/transactions_controller"
require "./controllers/users_controller"
require "./controllers/vulnerabilities_controller"
require "./controllers/auth_controller"
require "./helpers/auth_helpers"

current_user = nil

get "/" do |env|
  VulnerabilitiesController.home(env)
end

get "/users/login" do |_|
  render "src/views/auth/login.ecr", "src/views/layout.ecr"
end

post "/users/login" do |env|
  AuthController.login(env)
end

get "/users/logout" do |env|
  AuthController.logout(env)
end

get "/users/register" do |_|
  render "src/views/auth/register.ecr", "src/views/layout.ecr"
end

post "/users/register" do |env|
  UsersController.register(env)
end

get "/users/profile" do |env|
  UsersController.profile(env)
end

post "/users/transfer" do |env|
  TransactionsController.transfer(env)
end

get "/users/transfer" do |env|
  UsersController.transfer(env)
end

get "/users/:id" do |env|
  UsersController.show(env)
end

post "/users" do |env|
  UsersController.update(env)
end

get "/vulnerabilities" do |env|
  VulnerabilitiesController.index(env)
end

post "/vulnerabilities" do |env|
  VulnerabilitiesController.create(env)
end

get "/vulnerabilities/:id" do |env|
  VulnerabilitiesController.show(env)
end

post "/vulnerabilities/:id" do |env|
  VulnerabilitiesController.update(env)
end

get "/vulnerabilities/new" do |env|
  current_user = AuthHelpers.current_user(env)
  render "src/views/vulnerabilities/new.ecr", "src/views/layout.ecr"
end

get "/vulnerabilities/:id/buy" do |env|
  current_user = AuthHelpers.current_user(env)

  id = env.params.url["id"].to_i

  vulnerability = Vulnerability.find(id)
  if vulnerability
    render "src/views/vulnerabilities/buy.ecr", "src/views/layout.ecr"
  end
end

post "/vulnerabilities/:id/buy" do |env|
  VulnerabilitiesController.buy(env)
end

get "/transactions" do |env|
  TransactionsController.index(env)
end

get "/transactions/:id" do |env|
  TransactionsController.show(env)
end

post "/transactions/transfer" do |env|
  TransactionsController.transfer(env)
end

get "/about" do
  render "src/views/about.ecr", "src/views/layout.ecr"
end

get "/help" do
  render "src/views/help.ecr", "src/views/layout.ecr"
end

error 404 do
  render "src/views/notfound.ecr", "src/views/layout.ecr"
end

error 403 do
  render "src/views/notauthorize.ecr", "src/views/layout.ecr"
end
