defmodule Whisperer.Agent do
  @moduledoc """
  This behaviour defines the interface for agents in the Whisperer system.

  Agents are the building blocks of the Whisperer system. They are responsible for processing messages and generating responses.
  The Agent can be an LLM, a simple function, or a combination of both. It can be any kind of program that can take an input, perform some kind of task and return a response.

  This behaviour expects the implementing module to export a `characteristics/0` function that returns a map containing the agent's id, name, description, and capabilities.
  It also expects the implementing module to export a `process_message/3` function that takes in a message, the current context(a map of key-value pairs that can be used to store any information needed by the agent), and the conversation history, and returns an `:ok` tuple with the processed message or an `:error` tuple if there was an issue processing the message.

  ## Examples

      iex> MyApp.Agent.characteristics()
      %{id: "1", name: "Agent_a", description: "Agent a", capabilities: ["capability1"]}

      iex> MyApp.Agent.process_message(%Message{content: "Hello, how are you?"}, %{trace_id: "123"}, [])
      {:ok, %Message{content: "I'm doing great, thank you!"}}
  """

  alias Whisperer.Message

  @type agent_id :: String.t()
  @type agent_name :: String.t()
  @type agent_description :: String.t()
  @type context :: map()
  @type conversation_history :: [Message.t()]

  @type agent_characteristics :: %{
          id: agent_id,
          name: agent_name,
          description: agent_description,
          capabilities: [String.t()]
        }

  @callback characteristics() :: agent_characteristics

  @callback process_message(Message.t(), context, conversation_history) ::
              {:ok, Message.t()} | {:error, term()}
end
