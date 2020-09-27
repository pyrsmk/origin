require "../../src/wire"

struct OriginObject
  def return_float64 : Float64
    Random.rand
  end
end

struct TestObject
  wire define_int32_instead_of_float64_type : Int32,
       to: return_float64
  def initialize(@origin : OriginObject); end
end

TestObject.new(OriginObject.new).define_int32_instead_of_float64_type
