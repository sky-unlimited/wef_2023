# This class is a helper to deduct airac cycles depending source
class AiracCycle
  attr_reader :current_airac_cycle, :current_effective_date,
              :next_effective_date, :current_publication_date,
              :next_publication_date

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
    day_f = format('%02d', day.to_i)

    # Format month
    months = %w[JAN FEB MAR APR MAY JUN JUL AUG SEP OCT DEC]
    month_f = months[month.to_i - 1]

    "#{day_f}_#{month_f}_#{year}"
  end

  def convert_to_nl_format
    # Split in day, month and year
    day   = @current_publication_date.day
    month = @current_publication_date.month
    year  = @current_publication_date.year

    # Format day
    day_f = format('%02d', day.to_i)

    # Format month
    month_f = format('%02d', month.to_i)

    "#{year}-#{month_f}-#{day_f}-AIRAC"
  end

  private

  def update_current_cycle
    # Define initial cycle and its effective date
    initial_cycle = 2309
    initial_effective_date = Date.new(2023, 9, 7)

    # Current date
    current_date = Date.today

    # Calculate difference in days between current and initial date
    days_elapsed = (current_date - initial_effective_date).to_i

    # Calculate the current AIRAC cycle
    elapsed_cycles = (days_elapsed / 28)
    @current_airac_cycle = initial_cycle + elapsed_cycles
    @current_effective_date = initial_effective_date + (elapsed_cycles * 28)
    @next_effective_date = initial_effective_date + ((elapsed_cycles + 1) * 28)
    @current_publication_date = @current_effective_date - 42
    @next_publication_date = @next_effective_date - 42
  end
end
