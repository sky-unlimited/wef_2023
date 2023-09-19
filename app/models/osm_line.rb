class OsmLine < ApplicationRecord
  def parsed_tags
    # Assuming 'tags' column contains the string
    tags_str = self.tags

    # Remove the surrounding curly braces and whitespace
    cleaned_tags_str = tags_str.gsub(/\A\{|\}\z/, '').strip

    # Split the string into an array of key-value pairs
    tag_pairs = cleaned_tags_str.split(/\s*,\s*/)

    # Initialize an empty hash to store the parsed tags
    parsed_tags = {}

    # Iterate through the key-value pairs and add them to the hash
    tag_pairs.each do |pair|
      key, value = pair.split(/\s*=>\s*/)
      parsed_tags[key.gsub(/\A"|"\z/, '')] = value.gsub(/\A"|"\z/, '')
    end

    # Return the parsed tags as a hash
    parsed_tags
  end
end
