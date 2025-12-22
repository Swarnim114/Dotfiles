(exec
  (string) @content
  (#set! injection.language "bash"))

(keyword
  (name) @_name
  (#any-of? @_name "windowrule" "windowrulev2")
  (params
    (string)
    (string) @content
    (#set! injection.language "regex")))

(keyword
  (name) @_name
  (#match? @_name "bind(l|r|e|n|m|t|i)*")
  (params
    (_)+
    (string) @_function
    (#match? @_function ".*exec")
    (string) @content
    (#set! injection.language "bash")))
