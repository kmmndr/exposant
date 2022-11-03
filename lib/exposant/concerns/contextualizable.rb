module Exposant
  module Contextualizable
    attr_accessor :context

    def contextualize(context)
      self.context = context
    end

    def contextualized?
      context.present?
    end
  end
end
