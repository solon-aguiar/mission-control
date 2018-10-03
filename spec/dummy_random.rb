class DummyRandom
  def initialize(deterministic_limit, default_max = 0)
    @current_call = 0
    @deterministic_limit = deterministic_limit
    @default_max = default_max
  end

  def rand(max = @default_max)
    @current_call += 1

    @current_call > @deterministic_limit ? max - 1 : max
  end
end