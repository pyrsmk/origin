require "./helpers/spec_helper"

Spectator.describe "wire" do
  include CompileHelper

  private class OriginObject
    @value : String? = nil
    @array = [] of String
    def return_any_value
      [true, false, Random::Secure.hex, Random.rand(Int32), Random.rand].sample
    end
    def return_bool_for_bool_type : Bool
      [true, false].sample
    end
    def return_string_for_nilable_string_type : String?
      Random::Secure.hex
    end
    def return_nil_for_nilable_string_type : String?
      nil
    end
    def return_int32_for_int32_float64_union_type : Int32 | Float64
      Random.rand(Int32)
    end
    def return_float64_for_int32_float64_union_type : Int32 | Float64
      Random.rand
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
    def <<(value)
      @array << value
    end
    def []=(index, value)
      @array[index] = value
    end
    def [](index)
      @array[index]
    end
    def call_block(x : Int32)
      yield x
    end
  end

  private class TestObject
    wire return_bool_for_bool_type : Bool,
         to: return_bool_for_bool_type
    # Handling an alternate method name is implicitly tested here.
    wire return_any_value_for_any_type,
         to: return_any_value
    wire return_string_for_nilable_string_type : String?,
         to: return_string_for_nilable_string_type
    wire return_nil_for_nilable_string_type : String?,
         to: return_nil_for_nilable_string_type
    wire return_int32_for_int32_float64_union_type : Int32 | Float64,
         to: return_int32_for_int32_float64_union_type
    wire return_float64_for_int32_float64_union_type : Int32 | Float64,
         to: return_float64_for_int32_float64_union_type
    wire pass_specified_arguments,
         to: pass_specified_arguments
    wire :value=, to: :value=
    wire value, to: value
    wire :<<, to: :<<
    wire :[]=, to: :[]=
    wire :[], to: :[]
    wire call_block, to: call_block
    def initialize(@origin : OriginObject); end
  end

  subject { TestObject.new(OriginObject.new) }

  describe "types" do
    it "returns a valid value for a simple type" do
      expect(subject.return_bool_for_bool_type).to be_a(Bool)
    end

    it "does not compile when mismatching type definition" do
      expect(compile_fails("wire/wrong_typing")).to match(
        /method must return Int32 but it is returning Float64/i
      )
    end

    it "raises not an error when returning a value when no type is specified" do
      expect{subject.return_any_value_for_any_type}.to_not raise_error
    end

    it "returns a valid values for a nilable type" do
      expect(subject.return_string_for_nilable_string_type).to be_a(String)
      expect(subject.return_nil_for_nilable_string_type).to be_nil
    end

    it "returns valid values for an union type" do
      expect(subject.return_int32_for_int32_float64_union_type).to be_an(Int32)
      expect(subject.return_float64_for_int32_float64_union_type).to be_a(Float64)
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

    it "does not compile when passing a wrong type as 'from' argument" do
      expect(compile_fails("wire/bad_from_argument")).to match(
        /'from' parameter expects/i
      )
    end

    it "does not compile when passing a wrong type as 'to' argument" do
      expect(compile_fails("wire/bad_to_argument")).to match(
        /'to' parameter expects/i
      )
    end
  end

  describe "setters" do
    it "successfully sets a value with a simple setter" do
      value = Random::Secure.hex
      subject.value = value
      expect(subject.value).to eq value
    end

    it "sets values ins an array" do
      value = Random::Secure.hex
      subject << value
      expect(subject[0]).to eq value
      value2 = Random::Secure.hex
      subject[0] = value2
      expect(subject[0]).to eq value2
    end
  end

  describe "blocks" do
    it "calls the provided block" do
      value = rand(1..100)
      expect(subject.call_block(value){ |x| x * 2 }).to eq(value * 2)
    end
  end
end
