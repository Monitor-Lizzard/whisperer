defmodule Whisperer.Agent do
  @moduledoc """
  Behaviour that defines the interface for agents in the system.
  """

  alias Whisperer.Message

  @type agent_id :: String.t()
  @type agent_name :: String.t()
  @type agent_description :: String.t()
  @type context :: map()
  @type conversation_history :: [Message.t()]

  # TODO: Come up with an engine that comes up with this
  @type llm :: LangChain.ChatModels.t() | nil

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
