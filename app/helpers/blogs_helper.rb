# Manages helpers for blog
module BlogsHelper
  # returns an array of keywords
  def display_keywords(keywords)
    return if keywords.nil?

    keywords.sub(' ', '').split(',')
  end
end
