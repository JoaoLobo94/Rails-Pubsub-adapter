class CalculationJob < ApplicationJob
  queue_as(:default)

  # Perform a simple calculation

  # @param number1, number2 [Integer] The values you want to calculate
  # @return [Integer]
  def perform(number1, number2)
    (number1 + number2) * (number1 - number2)
  end
end
