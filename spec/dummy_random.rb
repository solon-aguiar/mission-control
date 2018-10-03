class DummyRandom
  def initialize(deterministic_limit)
    @current_call = 0
    @deterministic_limit = deterministic_limit
  end

  def rand(max)
    @current_call += 1

    @current_call > @deterministic_limit ? max - 1 : max
  end
end