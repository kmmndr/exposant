module Exposant
  module Collection
    include Enumerable

    def each
      return enum_for(:each) unless block_given?

      super { |o| yield o.exhibitor(self.class.exhibitor_variant) }
    end
  end
end
