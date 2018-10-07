module Unit
  def self.ms_to_se(ms)
    ms.to_f / 1000
  end

  def self.se_to_ms(se)
    se.to_f * 1000
  end

  def self.km_per_hour_to_km_per_se(km_per_hour)
    km_per_hour.to_f / 3600
  end

  def self.liters_per_minute_to_liters_per_sec(liters_per_minute)
    liters_per_minute.to_f / 60
  end
end