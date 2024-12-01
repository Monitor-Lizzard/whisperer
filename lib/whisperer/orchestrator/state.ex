defmodule Whisperer.Orchestrator.State do
  @moduledoc """
  Defines the state used by the orchestrator
  """

  alias Whisperer.{Agent, Message}

  @type conversations :: [Message.t()]

  @type context :: %{}

  @type t :: %__MODULE__{
          agents: %{Agent.agent_id() => module()},
          conversations: conversations,
          characteristics: [Agent.agent_characteristics()],
          context: %{},
          sequencer: module() | nil
        }

  defstruct agents: %{}, conversations: [], characteristics: [], context: %{}, sequencer: nil
end
