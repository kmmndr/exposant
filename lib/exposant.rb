# frozen_string_literal: true

require 'delegate'
require 'active_support'
require 'active_model'

require_relative 'exposant/concerns/contextualizable'
require_relative 'exposant/concerns/collection'
require_relative 'exposant/model'
require_relative 'exposant/base'
require_relative 'exposant/version'

module Exposant
  class Error < StandardError; end
end
