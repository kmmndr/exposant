module Exposant
  class CollectionExhibitor < SimpleDelegator
    include Exhibitor
    extend ActiveModel::Naming
    include Enumerable

    def self.exhibitor_variant
      self::MODEL_PRESENTER_VARIANT if const_defined?('MODEL_PRESENTER_VARIANT')
    end

    def each
      return enum_for(:each) unless block_given?

      __getobj__.each { |o| yield o.exhibitor(self.class.exhibitor_variant) }
    end

    def to_model
      self
    end
  end
end
