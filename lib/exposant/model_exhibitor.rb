module Exposant
  class ModelExhibitor < SimpleDelegator
    include Exhibitor
    extend ActiveModel::Naming

    def to_model
      obj
    end

    def self.human_attribute_name(*args)
      exhibited_class.human_attribute_name(*args)
    end

    def self.exhibited_class
      return ancestors[1].exhibited_class unless ancestors[1] == ModelExhibitor

      name.gsub(/Exhibitor$/, '').constantize
    end

    def self.exhibitor_variant
      variant = name[parent_exhibitor.exhibited_class.name.length..].gsub(/Exhibitor$/, '').downcase

      return nil if variant.blank?

      variant.to_sym
    end

    def self.parent_exhibitor
      return ancestors[1].parent_exhibitor unless ancestors[1] == ModelExhibitor

      name.constantize
    end
  end
end
