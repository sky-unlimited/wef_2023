WEF_CONFIG = YAML.load_file(Rails.root.join('config', 'wef_config.yml'), aliases: true)[Rails.env]
