(comment) @comment

[
  "source"
  "exec-once"
  "execr-once"
  "exec"
  "execr"
  "exec-shutdown"
] @property

(keyword
  (name) @property)

(assignment
  (name) @property)

(section
  (name) @module)

(window_rule
  (name) @function)

(section
  device: (device_name) @type)

(variable) @variable

"$" @punctuation.special

(boolean) @boolean

(mod) @constant

[
  "rgb"
  "rgba"
] @function

[
  (number)
  (legacy_hex)
  (angle)
  (hex)
  (display)
  (position)
] @number

"deg" @type

[
  ","
  ";"
] @punctuation.delimiter

[
  "("
  ")"
  "{"
  "}"
  "["
  "]"
] @punctuation.bracket

[
  "="
  "-"
  "+"
] @operator

(string_literal) @string
