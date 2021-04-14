require "rspec/its"
require 'rspec/temp_dir'

require "toggles"

Bundler.require(:test)

RSpec.configure do |config|
  config.order = "random"

  config.before(:each) do
    Toggles.configure do |c|
      c.features_dir = "features"
    end
  end
end
