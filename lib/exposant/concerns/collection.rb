module Exposant
  module Collection
    include Enumerable

    def each
      return enum_for(:each) unless block_given?

      super { |o| yield o.exposant(self.class.exposant_variant) }
    end
  end
end
