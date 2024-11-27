defmodule Whisperer.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Whisperer.OrchestratorRegistry},
      {Whisperer.Orchestrator.Supervisor, []},
      {Whisperer.Langchain.Config,
       [
         model: Application.get_env(:whisperer, :llm_model, "gpt-3.5-turbo")
       ]}
    ]

    opts = [strategy: :one_for_one, name: Whisperer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
