defmodule Whisperer.Message do
  @moduledoc """
  Defines the message structure used by the orchestrator
  """

  @type content :: String.t()

  @type t :: %__MODULE__{
          role: :user | :assistant | :system,
          content: content(),
          agent_id: Whisperer.Agent.agent_id() | nil,
          timestamp: DateTime.t()
        }

  defstruct ~w[role content agent_id timestamp]a
end
