require_relative './engine'
require_relative './rocket'
require_relative '../config'

module RocketFactory
  def self.build_rocket(seed)
    random_number_generator = Random.new(seed)

    engine = Rocket::Engine.new(Config::ENGINE_AVERAGE_SPEED, random_number_generator)
    Rocket::Rocket.new(Config::ROCKET_AVERAGE_BURN_RATE, engine)
  end
end