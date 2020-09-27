require "./helpers/spec_helper"

# We're not testing everything here as `autowire` relies on `wire`. Hence,
# we'll only test that calls are correctly passed to `wire`macro.
Spectator.describe "autowire" do
  include CompileHelper

  private class OriginObject
    @value : String? = nil
    def simple_method
      Random.rand(Int8)
    end
    def method_with_type : String
      Random::Secure.hex
    end
    def pass_specified_arguments(*args, **options)
      [args, options]
    end
    def value=(value)
      @value = value
    end
    def value
      @value
    end
    def call_block(x : Int32)
      yield x
    end
  end

  private class TestObject
    autowire simple_method,
             method_with_type : String,
             pass_specified_arguments,
             :value=,
             value,
             call_block
    def initialize(@origin : OriginObject); end
  end

  subject { TestObject.new(OriginObject.new) }

  describe "base" do
    it "calls methods correctly" do
      expect(subject.simple_method).to be_an(Int8)
      expect(subject.method_with_type).to be_a(String)
    end
  end

  describe "arguments" do
    let(fruits) { { "apple", "strawberry", "pear" } }
    let(vegetables) { { potatos: 1, onions: 2, tomatos: 3 } }

    it "passes arguments correctly" do
      args, options = subject.pass_specified_arguments(*fruits, **vegetables)
      expect(args).to eq fruits
      expect(options).to eq vegetables
    end
  end

  describe "setters" do
    it "successfully sets a value with a simple setter" do
      value = Random::Secure.hex
      subject.value = value
      expect(subject.value).to eq value
    end
  end

  describe "blocks" do
    it "calls the provided block" do
      value = rand(1..100)
      expect(subject.call_block(value){ |x| x * 2 }).to eq(value * 2)
    end
  end
end
