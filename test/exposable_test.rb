require 'test_helper'

class ExposableTest < Minitest::Test
  class Foo
    include Exposant::Model

    def self.klass_method
      1
    end

    def baz
      2
    end

    def original_method
      3
    end

    def self.original_klass_method
      4
    end
  end

  class FooExhibitor < Exposant::Base
    def self.klass_method
      super + 2
    end

    def baz
      super + 4
    end

    # original_method
    # self.original_klass_method

    def self.other_klass_method
      8
    end
  end

  class FooBarExhibitor < FooExhibitor; end

  def test_instance_exhibitor
    assert_equal FooExhibitor, Foo.new.exhibitor.class
    assert_equal FooBarExhibitor, Foo.new.exhibitor(:bar).class

    assert_nil Foo.new.exhibitor.class.exhibitor_variant
    assert_equal :bar, Foo.new.exhibitor(:bar).class.exhibitor_variant

    assert_equal Foo, Foo.new.exhibitor.class.exhibited_class
    assert_equal Foo, Foo.new.exhibitor(:bar).class.exhibited_class

    assert_equal FooExhibitor, Foo.new.exhibitor.exhibitor.class

    assert Foo.new.respond_to?(:baz)
    assert_equal 2, Foo.new.baz
    assert Foo.new.exhibitor.respond_to?(:baz)
    assert_equal 6, Foo.new.exhibitor.baz
    assert Foo.new.exhibitor.respond_to?(:original_method)
    assert_equal 3, Foo.new.exhibitor.original_method
  end

  def test_class_exhibitor
    foos = [Foo.new, Foo.new]

    refute foos.respond_to? :exhibitor
    Foo.exhibitor(foos)
    refute [].respond_to? :exhibitor

    assert_equal FooExhibitor, foos.exhibitor.class
    assert_equal FooBarExhibitor, foos.exhibitor(:bar).class

    assert_nil FooExhibitor.exhibitor_variant
    assert_equal :bar, FooBarExhibitor.exhibitor_variant

    assert_equal FooExhibitor, foos.exhibitor.first.class
    assert_equal FooBarExhibitor, foos.exhibitor(:bar).first.class
    assert_equal FooExhibitor, FooExhibitor.new(foos).first.class
    assert_equal FooBarExhibitor, FooBarExhibitor.new(foos).first.class

    assert_equal 1, Foo.klass_method
    assert_equal 3, FooExhibitor.klass_method
    assert FooExhibitor.respond_to?(:original_klass_method)
    assert_equal 4, FooExhibitor.original_klass_method
    assert FooExhibitor.respond_to?(:other_klass_method)
    assert_equal 8, FooExhibitor.other_klass_method
  end

  def test_exhibitor_context
    foo_exhibitor = Foo.new.exhibitor
    refute foo_exhibitor.contextualized?
    foo_exhibitor.contextualize(123)
    assert foo_exhibitor.contextualized?
    assert_equal 123, foo_exhibitor.context

    foos = [Foo.new]
    foos_exhibitor = Foo.exhibitor(foos)
    refute foos_exhibitor.contextualized?
    foos_exhibitor.contextualize({ a: 1 })
    assert foos_exhibitor.contextualized?
    assert_equal ({ a: 1 }), foos_exhibitor.context
  end
end
