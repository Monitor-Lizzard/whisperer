defmodule Whisperer do
  @moduledoc """
  Documentation for `Whisperer`.
  """

  alias Whisperer.{Message, Orchestrator, Orchestrator.Supervisor}

  @doc """
  Starts a new session to be used with the orchestrator.
  This can be directly mapped to a websocket connection on your application for a user session.

  It accepts the following arguments:
  - an identifier for the session (e.g. a websocket connection id or even a name; just has to be a unique identifier)
  - a sequencer module. This is the module defined in your application that will handle the sequencing of the agents. It must implement the `Whisperer.Sequencer` behaviour.
  - a context map. This is a map of context that will be passed to the agents and used to process the messages.
  You can use this to pass in any information you want to be available to the agents, e.g user information, session information, observability information, etc.

  It returns an `:ok` tuple with the pid of the orchestrator process.

  ## Examples

      iex> Whisperer.start_session("123", MyApp.Sequencer.Basic, %{})
      {:ok, pid}
  """
  @spec start_session(String.t(), module(), map()) ::
          :ignore | {:error, any()} | {:ok, pid()} | {:ok, pid(), any()}
  def start_session(session_id, sequencer, context) do
    Supervisor.start_orchestrator(session_id, sequencer, context)
  end

  @doc """
  Adds an agent to the orchestrator for the given session.
  An agent is a module that implements the `Whisperer.Agent` behaviour.

  It returns an `:ok` tuple.

  ## Examples

      iex> Whisperer.add_agent("123", MyApp.Agent)
      :ok
  """
  @spec add_agent(String.t(), module()) :: :ok
  def add_agent(session_id, agent_module) do
    Orchestrator.add_agent(session_id, agent_module)
  end

  @doc """
  Processes user input for a session.

  It returns an `:ok` tuple with the processed message or an `:error` tuple if there was an issue processing the message.

  Internally, it uses the Sequencer module provided when starting the session to create a sequence of agents to be used to process the input, and then uses the Orchestrator to process the message through the sequence.

  ## Examples

      iex> Whisperer.process_user_input("123", "Hello, how are you?")
      {:ok, %Whisperer.Message{content: "I'm doing great, thank you!"}}
  """
  @spec process_user_input(String.t(), String.t()) :: {:ok, Message.t()} | {:error, term()}
  def process_user_input(session_id, user_input) do
    Orchestrator.process_user_input(session_id, user_input)
  end

  @doc """
  Gets the conversation for a session.

  It returns an `:ok` tuple with the conversation history for the session or an `:error` tuple if there was an issue getting the conversation.

  ## Examples

      iex> Whisperer.get_conversation("123")
      {:ok, [%Message{content: "Hello, how are you?"}, %Message{content: "I'm doing great, thank you!"}]}
  """
  @spec get_conversation(String.t()) :: [Message.t()] | {:error, term()}
  def get_conversation(session_id) do
    Orchestrator.get_conversation(session_id)
  end
end
