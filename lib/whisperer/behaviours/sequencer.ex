defmodule Whisperer.Sequencer do
  @moduledoc """
  This behaviour defines the interface for a sequencer in the Whisperer system.

  A sequencer is a module responsible for selecting the agents to be used based on the user input, and generating a sequence of agents that will be used to process the input.
  The sequencer does not handle the actual processing of messages, it only decides which agents from the given list of agents should be used and in what order they should be used by the orchestrator.

  This behaviour expects the implementing module to export a `create_sequence/3` function that takes in the user input, the list of all available agents in a specified format, and the conversation history (for context window purposes), and returns an `:ok` tuple with the sequence or an `:error` tuple if there was an issue creating the sequence.

  The `create_sequence/3` function should return a `Whisperer.Sequence` struct that contains the starting agent and a graph that shows the connections between the agents.

  The implementation of the `create_sequence/3` function should take into account the input, capabilities of the agents and the context window of the conversation history. The implementation can use an LLM or just a simple algorithm to generate the sequence using regular functions.

  ## Examples

      iex> MyApp.Sequencer.create_sequence("Hello, how are you?", [%{id: "1", name: "Agent 1", description: "Agent 1", capabilities: ["capability1"]}, %{id: "2", name: "Agent 2", description: "Agent 2", capabilities: ["capability2"]}], [])
      {:ok, %Whisperer.Sequence{
        start_agent: "agent_a",
        connections: %{"agent_a" => ["agent_b"], "agent_b" => ["agent_c"]}
      }}
  """

  alias Whisperer.{Agent, Message, Sequence}

  @callback create_sequence(Message.content(), [Agent.agent_characteristics()], [Message.t()]) ::
              {:ok, Sequence.t()} | {:error, term()}
end
