defmodule Whisperer.Agent do
  @moduledoc """
  Behaviour that defines the interface for agents in the system.
  """

  @type agent_id :: String.t()
  @type agent_name :: String.t()
  @type agent_description :: String.t()
  @type user_id :: String.t()
  @type session_id :: String.t()
  @type message :: String.t()

  @type agent_characteristics :: %{
    id: agent_id,
    name: agent_name,
    description: agent_description,
    capabilities: [String.t()]
  }

  @callback characteristics() :: agent_characteristics

  @callback process_message(message, user_id, session_id, context :: map()) ::
    {:ok, message} | {:error, term()}
end
