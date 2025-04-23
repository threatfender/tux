# Used by "mix format"
[
  locals_without_parens: [
    # Command registration
    cmd: 2,
    cmd: 3,
    pre: 2,

    # Module creation
    program: 2,
    dispatcher: 2,
    command: 2,

    # Testing
    scenario: 2,
    execute: 2,
    enter: 2
  ],
  export: [
    locals_without_parens: [
      cmd: 2,
      cmd: 3,
      pre: 2,
      program: 2,
      dispatcher: 2,
      command: 2,
      scenario: 2,
      execute: 2
    ]
  ],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
]
