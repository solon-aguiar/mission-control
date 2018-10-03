class DummyRandom
  def initialize(deterministic_limit, default_max = 0)
    @current_call = 0
    @deterministic_limit = deterministic_limit
    @default_max = default_max
  end

  def rand(range = 0..@default_max)
    @current_call += 1

    @current_call > @deterministic_limit ? range.end - 1 : range.end
  end
end