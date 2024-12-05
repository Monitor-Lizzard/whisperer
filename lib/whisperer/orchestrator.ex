defmodule Whisperer.Orchestrator do
  @moduledoc """
  Main orchestrator module that manages the flow of messages between users and agents.
  Maintains state in its own process using GenServer.
  TODO: Explore conversation history per agent
  """

  use GenServer
  alias Whisperer.{Message, Orchestrator.State, Orchestrator.Supervisor, Sequence}

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
  1. Adds the received user message to the conversation history.
  2. Uses the sequencer to create a plan for executing the agents.
  """
  @spec process_user_input(String.t(), Message.content()) ::
          {:ok, String.t()} | {:error, term()}
  def process_user_input(session_id, user_input) do
    with {:ok, orchestrator} <- Supervisor.get_orchestrator(session_id) do
      GenServer.call(orchestrator, {:process_user_input, user_input})
    end
  end

  @doc """
  Registers a new agent with the orchestrator.
  """
  def add_agent(session_id, agent_module) when is_atom(agent_module) do
    with {:ok, orchestrator} <- Supervisor.get_orchestrator(session_id) do
      GenServer.call(orchestrator, {:add_agent, agent_module})
    end
  end

  @doc """
  Gets the conversation history for a user's session.
  """
  @spec get_conversation(binary()) :: [State.message()]
  def get_conversation(session_id) do
    with {:ok, orchestrator} <- Supervisor.get_orchestrator(session_id) do
      GenServer.call(orchestrator, {:get_conversation})
    end
  end

  # Server Callbacks

  @impl true
  def init(opts) do
    {:ok, %State{context: Keyword.get(opts, :context, %{}), sequencer: opts[:sequencer]}}
  end

  @impl true
  def handle_call(
        {:add_agent, agent_module},
        _from,
        %{agents: agents, characteristics: characteristics} = state
      ) do
    agent_characteristics = agent_module.characteristics()
    state
    |> Map.put(:agents, Map.put(agents, agent_characteristics.id, agent_module))
    |> Map.put(:characteristics, [agent_characteristics | characteristics])
    |> then(&{:reply, :ok, &1})
  end

  @impl true
  def handle_call({:process_user_input, user_input}, _from, state) do
    with %State{} = state <- add_message(state, :user, user_input),
         {:ok, %Sequence{start_agent: start_agent} = sequence}  <-
           state.sequencer.create_sequence(user_input, state.characteristics, state.conversations),
           false <- is_nil(start_agent),
         {:ok, %_{conversations: [response | _]} = state} <- bfs(state, sequence.connections, [start_agent], MapSet.new()) do
      {:reply, {:ok, response}, state}
    end
  end

  @impl true
  def handle_call({:get_conversation}, _from, state), do: {:reply, state.conversations, state}

  # Internal Functions
  defp add_message(state, role, content, agent_id \\ nil) do
    message = %Message{
      role: role,
      content: content,
      agent_id: agent_id,
      timestamp: DateTime.utc_now()
    }

    %{state | conversations: [message | state.conversations]}
  end

  # TODO: support multiple children from a node
  defp bfs(state, _graph, [], _visited), do: {:ok, state}

  defp bfs(state, graph, [current_node | queue], visited) do
    case MapSet.member?(visited, current_node) do
      true ->
        bfs(state, graph, queue, visited)

      false ->
        [message | _] = state.conversations
        neighbors = Map.get(graph, current_node, [])

        {:ok, response} =
          state.agents[current_node].process_message(message, state.context, state.conversations)

        updated_state = add_message(state, :assistant, response.content, current_node)
        bfs(updated_state, graph, queue ++ neighbors, MapSet.put(visited, current_node))
    end
  end
end
