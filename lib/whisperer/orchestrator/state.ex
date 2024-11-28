defmodule Whisperer.Orchestrator.State do
  @moduledoc """
  Defines the state used by the orchestrator
  """

  alias Whisperer.Agent

  @type message :: %{
    role: :user | :assistant | :system,
    content: String.t(),
    agent_id: Agent.agent_id() | nil,
    timestamp: DateTime.t()
  }

  @type conversations :: [message]

  @type context :: %{}

  @type t :: %__MODULE__{
    agents: %{Agent.agent_id() => module()},
    conversations: conversations,
    characteristics: [Agent.agent_characteristics()],
    context: %{}
  }

  defstruct agents: %{}, conversations: [], characteristics: [], context: %{}
end
