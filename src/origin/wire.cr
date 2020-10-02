# Define instance methods to decorate methods on `@origin`.
# @param from [TypeDeclaration | Call]
# @param to [Call]
macro wire(from, to, return_type = nil)
  # Verify parameters
  {%
    if !%w(TypeDeclaration Call SymbolLiteral).includes?(from.class_name)
      raise "'from' parameter expects a method name with or without " \
            "a type declaration."
    end
  %}
  {%
    if !to.is_a?(Call) && !to.is_a?(SymbolLiteral)
      raise "'to' parameter expects a method name."
    end
  %}
  # Prepare the method name
  {%
    method_name = if from.is_a?(TypeDeclaration)
                    from.var.id
                  else
                    from.id
                  end
  %}
  # Prepare the return type
  {%
    if return_type.is_a?(NilLiteral)
      if from.is_a?(TypeDeclaration)
        return_type = " : #{from.type.id}"
      end
    elsif return_type.is_a?(Path)
      return_type = " : #{return_type.resolve.id}"
    else
      raise "'return_type' parameter expects a type."
    end
  %}
  # Generate the methods
  {% if method_name.id.ends_with?('=') && method_name.id != "[]=" %}
    # Handle setters
    def {{method_name.id}}(arg)
      @origin.{{to.id}}(arg)
    end
  {% else %}
    # Handle basic methods
    def {{method_name.id}}(*args, **options){{return_type.id}}
      @origin.{{to.id}}(*args, **options)
    end
    # Handle blocks
    {% if method_name.id != "[]=" %}
      def {{method_name.id}}(*args, **options){{return_type.id}}
        @origin.{{method_name.id}}(*args, **options) do |*yield_args|
          yield *yield_args
        end
      end
    {% end %}
  {% end %}
end
