module Exposant
  class Base < SimpleDelegator
    include Exposant::Contextualizable
    extend ActiveModel::Naming

    def initialize(*)
      super

      extend(Exposant::Collection) if __getobj__.is_a?(Enumerable)
    end

    def to_model
      __getobj__
    end

    def self.respond_to_missing?(name, *)
      klass.respond_to?(name) || super
    end

    def self.method_missing(name, *args, &block)
      klass.send(name, *args, &block)
    end

    def self.human_attribute_name(*args)
      exhibited_class.human_attribute_name(*args)
    end

    def self.klass
      @klass ||= exhibited_class
    end

    def self.exhibited_class
      return ancestors[1].exhibited_class unless ancestors[1] == Exposant::Base

      name.gsub(/Exhibitor$/, '').constantize
    end

    def self.exhibitor_variant
      variant = name[parent_exhibitor.exhibited_class.name.length..].gsub(/Exhibitor$/, '').downcase

      return nil if variant.blank?

      variant.to_sym
    end

    def self.parent_exhibitor
      return ancestors[1].parent_exhibitor unless ancestors[1] == Exposant::Base

      name.constantize
    end
  end
end
