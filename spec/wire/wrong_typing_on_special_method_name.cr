require "../../src/origin/wire"

struct OriginObject
  @array = [Random::Secure.hex]
  def [](index : Int32) : String
    @array[index]
  end
end

struct TestObject
  wire :[], return_type: Int32, to: :[]
  def initialize(@origin : OriginObject); end
end

TestObject.new(OriginObject.new)[0]
