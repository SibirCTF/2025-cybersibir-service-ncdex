module Bonus
  def self.welcome_from_exchange(balance : Int32) : Int32
    bonus = balance // 1000
    bonus < 100 ? 0 : bonus
  end
end
