# frozen_string_literal: true

require 'delegate'
require 'active_support'
require 'active_model'

require_relative 'exposant/concerns/contextualizable'
require_relative 'exposant/concerns/exhibitor'
require_relative 'exposant/concerns/exposable'
require_relative 'exposant/collection_exhibitor'
require_relative 'exposant/model_exhibitor'
require_relative 'exposant/version'

module Exposant
  class Error < StandardError; end
  # Your code goes here...
end
