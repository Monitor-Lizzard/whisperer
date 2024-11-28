defmodule Whisperer.Orchestrator do
  @moduledoc """
  Main orchestrator module that manages the flow of messages between users and agents.
  Maintains state in its own process using GenServer.
  """

  use GenServer
  alias Whisperer.{Agent, Classifier, Orchestrator.State}

  # Client API

  @doc """
  Starts the orchestrator process.
  """
  def start_link(opts) do
    name = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @doc """
  Processes a user message through the appropriate agent.
  """
  @spec process_message(String.t(), Agent.user_id(), Agent.session_id()) ::
    {:ok, String.t()} | {:error, term()}
  def process_message(message, user_id, session_id) do
    case Whisperer.Orchestrator.Supervisor.get_orchestrator(session_id) do
      {:ok, orchestrator} ->
        GenServer.call(orchestrator, {:process_message, message, user_id, session_id})
      error ->
        error
    end
  end

  @doc """
  Registers a new agent with the orchestrator.
  """
  def add_agent(session_id, agent_module) when is_atom(agent_module) do
    case Whisperer.Orchestrator.Supervisor.get_orchestrator(session_id) do
      {:ok, orchestrator} ->
        GenServer.call(orchestrator, {:add_agent, agent_module})
      error ->
        error
    end
  end

  @doc """
  Gets the conversation history for a user's session.
  """
  @spec get_conversation(Agent.user_id(), Agent.session_id()) :: [conversation]
  def get_conversation(user_id, session_id) do
    case Whisperer.Orchestrator.Supervisor.get_orchestrator(session_id) do
      {:ok, orchestrator} ->
        GenServer.call(orchestrator, {:get_conversation, user_id, session_id})
      _error ->
        []
    end
  end

  # Server Callbacks

  @impl true
  def init(opts) do
    {:ok, %State{context: Keyword.get(opts, :context, %{})}}
  end

  @impl true
  def handle_call(:new, _from, _state) do
    new_state = %__MODULE__{}
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call({:add_agent, agent_module}, _from, %{agents: agents, characteristics: characteristics} = state) do
    agent_characteristics = agent_module.characteristics()

    state
    |> Map.put(:agents, Map.put(state.agents, characteristics.id, agent_module))
    |> Map.put(:characteristics, [agent_characteristics | characteristics])
    |> then(&{:reply, :ok, &1})
  end

  @impl true
  def handle_call({:process_message, message}, _from, state) do
    # Step 1: Add user message to history first
    state = add_message_internal(state, user_id, session_id, :user, message, nil)

    # Step 2: Get agent characteristics for classification
    conversation_history = get_conversation_internal(state, user_id, session_id)

    # Step 3: Classify the message
    with {:ok, agent_id} <- Classifier.classify(message, user_id, session_id, conversation_history, state.characteristics),
         agent_module when not is_nil(agent_module) <- Map.get(state.agents, agent_id) do



      # Step 4: Process message with selected agent
      case agent_module.process_message(message, user_id, session_id, %{
        conversation_history: conversation_history
      }) do
        {:ok, response} ->
          # Step 5: Add agent response to history
          state = add_message_internal(state, user_id, session_id, :assistant, response, agent_id)
          {:reply, {:ok, response}, state}

        {:error, reason} ->
          {:reply, {:error, reason}, state}
      end
    else
      nil -> {:reply, {:error, :agent_not_found}, state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call({:get_conversation, user_id, session_id}, _from, state) do
    conversation = get_conversation_internal(state, user_id, session_id)
    {:reply, conversation, state}
  end

  # Internal Functions

  defp get_conversation_internal(state, user_id, session_id) do
    conversation_key = {user_id, session_id}
    state.conversations
    |> Map.get(conversation_key, [])
    |> Enum.reverse() # Return messages in chronological order
  end

  defp add_message(state, role, content, agent_id \\ nil) do
    message = %{
      role: role,
      content: content,
      agent_id: agent_id,
      timestamp: DateTime.utc_now()
    }

    new_conversations = Map.update(
      state.conversations,
      conversation_key,
      [message],
      &[message | &1] # Add new messages to the front of the list
    )

    %{state | conversations: new_conversations}
  end

  defp get_agent_characteristics(state) do
    state.agents
    |> Enum.map(fn {_id, module} -> module.characteristics() end)
  end
end
