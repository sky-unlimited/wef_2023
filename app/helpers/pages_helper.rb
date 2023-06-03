module PagesHelper
  def displayFlag(country)
    case country
    when :en
      return '🇬🇧'
    when :fr
      return '🇨🇵'
    end
  end
end
