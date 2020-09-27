# TODO make a custom matcher instead of a helper.
# https://gitlab.com/arctic-fox/spectator/-/wikis/Custom-Matchers

class String
  def trail(str : String) : String
    return self + str if !(self =~ Regex.new("#{Regex.escape(str)}$"))
    self
  end
end

class SuccessfulCompileError < Exception; end

module CompileHelper
  def compile_fails(path : String) : String
    buffer = IO::Memory.new
    result = Process.run(
      "crystal",
      ["run", "--no-color", "--no-codegen", "spec/" + path.trail(".cr")],
      error: buffer,
    )
    raise SuccessfulCompileError.new if result.success?
    output = buffer.to_s
    buffer.close
    output
  end
end
