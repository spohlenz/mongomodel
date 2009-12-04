# For the purposes of tests, we ignore fractions of a second when comparing Time objects
class Time
  def ==(other)
    super(other) || to_s == other.to_s
  end
end
