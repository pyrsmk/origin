# Simpler declaration for wiring methods on @origin with the same method name.
# @param methods [ArrayLiteral(TypeDeclaration | Call)]
macro autowire(*methods)
  {% for method in methods %}
    {%
      method_name = if method.is_a?(TypeDeclaration)
                      method.var.id
                    else
                      method
                    end
    %}
    wire {{method}}, to: {{method_name}}
  {% end %}
end
