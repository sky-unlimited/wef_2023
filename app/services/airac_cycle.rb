class AiracCycle

  attr_reader :current_airac_cycle, :current_effective_date, :next_effective_date

  def initialize
    @current_airac_cycle = 0 
    @current_effective_date = nil
    @next_effective_date = nil

    update_current_cycle
  end

  def convert_to_sia_format
    # Split in day, month and year
    day   = @current_effective_date.day
    month = @current_effective_date.month
    year  = @current_effective_date.year

    # Format day
    day_f = sprintf("%02d", day.to_i)

    # Format month
    month_f = case month.to_i
      when 1
        "JAN"
      when 2
        "FEB"
      when 3
        "MAR"
      when 4
        "APR"
      when 5
        "MAY"
      when 6
        "JUN"
      when 7
        "JUL"
      when 8
        "AUG"
      when 9
        "SEP"
      when 10
        "OCT"
      when 11
        "NOV"
      when 12
        "DEC"
      else
        "Invalid Month"
      end

    return "#{day_f}_#{month_f}_#{year}"
  end

  private

  def update_current_cycle
    # Define an initial cycle and its effective date
    initial_cycle = 2309
    initial_effective_date = Date.new(2023, 9, 7)

    # Current date
    current_date = Date.today

    # Calculate the difference in days between the current date and the initial date
    days_elapsed = (current_date - initial_effective_date).to_i

    # Calculate the current AIRAC cycle
    elapsed_cycles = (days_elapsed / 28)
    @current_airac_cycle = initial_cycle + elapsed_cycles
    @current_effective_date = initial_effective_date + (elapsed_cycles * 28)
    @next_effective_date = initial_effective_date + ((elapsed_cycles + 1) * 28)
  end
end
