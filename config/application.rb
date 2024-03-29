require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Wef
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Europe/Paris"
    # config.eager_load_paths << Rails.root.join("extras")
    
    ###
    # ** Please read carefully, this must be configured in config/application.rb **
    #
    # Change the format of the cache entry.
    #
    # Changing this default means that all new cache entries added to the cache
    # will have a different format that is not supported by Rails 7.0
    # applications.
    #
    # Only change this value after your application is fully deployed to Rails 7.1
    # and you have no plans to rollback.
    # When you're ready to change format, add this to `config/application.rb` (NOT
    # this file):
    config.active_support.cache_format_version = 7.1

    # Cache store
    config.cache_store = :mem_cache_store # Will fallback to $MEMCACHE_SERVERS, then 127.0.0.1:11211

    # solid_queue
    config.solid_queue.silence_polling = true

  end
end
