defmodule Whisperer.Orchestrator.Supervisor do
  @moduledoc """
  Dynamic supervisor for orchestrator processes.
  Each session gets its own orchestrator process.
  """

  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Starts a new orchestrator process for a session.
  """
  @spec start_orchestrator(binary(), module(), map()) ::
          :ignore | {:error, any()} | {:ok, pid()} | {:ok, pid(), any()}
  def start_orchestrator(session_id, sequencer, context) do
    child_spec =
      {Whisperer.Orchestrator,
       name: via_tuple(session_id), context: context, sequencer: sequencer}

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @doc """
  Returns the process name for a session's orchestrator.
  """
  def via_tuple(session_id) do
    {:via, Registry, {Whisperer.OrchestratorRegistry, session_id}}
  end

  @doc """
  Gets the orchestrator process for a session, starting one if it doesn't exist.
  """
  def get_orchestrator(session_id) do
    case Registry.lookup(Whisperer.OrchestratorRegistry, session_id) do
      [{pid, _}] ->
        {:ok, pid}

      [] ->
        raise "Orchestrator not found for session #{session_id}"
    end
  end
end
