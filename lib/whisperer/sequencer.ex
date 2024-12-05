defmodule Whisperer.Sequencer do
  @moduledoc """
  Handles Sequencing of agents based on input.
  """

  alias Whisperer.{Agent, Message, Sequence}

  @callback create_sequence(Message.content(), [Agent.agent_characteristics()], [Message.t()]) ::
              {:ok, Sequence.t()} | {:error, term()}
end
