# For the purposes of tests, we ignore fractions of a second when comparing Time objects
class Time
  def ==(other)
    super(other) || utc.to_s == other.utc.to_s if other
  end
end
