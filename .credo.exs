%{
  configs: [
    %{
      name: "default",
      checks: %{
        disabled: [
          {Credo.Check.Design.TagTODO, []},
        ]
      }
    }
  ]
}
