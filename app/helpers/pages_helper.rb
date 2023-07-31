module PagesHelper
  def displayFlag(country)
    case country
    when :en
      return '🇬🇧'
    when :fr
      return '🇨🇵'
    end
  end
  def readable_number(number)
    if number >= 1000
      # Convert to "x.yK" format
      "%.1fK" % (number / 1000.0)
    elsif number >= 100
      # Convert to ">x00" format
      ">#{number / 100 * 100}"
    else
      number.to_s
    end
  end
end
