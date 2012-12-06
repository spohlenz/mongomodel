module ValidationHelpers
  def clear_validations! 
    reset_callbacks(:validate)
  end
end
