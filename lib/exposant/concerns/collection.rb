module Exposant
  module Collection
    include Enumerable

    def each
      return enum_for(:each) unless block_given?

      super do |obj|
        exposant = obj.exposant(self.class.exposant_variant, self.class.exposant_type)
        exposant.contextualize(context) if contextualized?

        yield exposant
      end
    end
  end
end
