require 'dotenv'
Dotenv.load('.env.test')

require 'rom/elasticsearch'
require_relative 'support/helpers'

RSpec.configure do |config|
  config.include Helpers
end
