defmodule Whisperer.Sequence do
  @moduledoc """
  Defines the relationship between the agents as an execution sequence.
  """
  alias Whisperer.Agent

  @type connections :: %{Agent.agent_id() => [Agent.agent_id()]}

  @type t :: %__MODULE__{
          start_agent: Agent.agent_id(),
          connections: connections()
        }

  defstruct ~w[start_agent connections]a
end
