defmodule Whisperer.Sequencer do
  @moduledoc """
  Handles Sequencing of agents based on input.
  """

  alias Whisperer.{Agent, Sequence}
  alias Whisperer.Orchestrator.State

  @callback create_sequence(State.content(), [Agent.agent_characteristics()], [State.message()]) ::
              {:ok, Sequence.t()} | {:error, term()}
end
