%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "test/"],
      },
      plugins: [],
      requires: [],
      strict: false,
      parse_timeout: 5000,
      color: true,
      checks: [
        {Credo.Check.Design.AliasUsage, priority: :low},
        # ... other checks omitted for readability ...
      ]
    }
  ]
}
