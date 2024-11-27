defmodule Whisperer.Langchain.Config do
  @moduledoc """
  Configuration module for LangChain integration.
  """

  use GenServer

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get_llm do
    GenServer.call(__MODULE__, :get_llm)
  end

  # Server Callbacks

  @impl true
  def init(opts) do
    llm = setup_llm(opts)
    {:ok, %{llm: llm}}
  end

  @impl true
  def handle_call(:get_llm, _from, state) do
    {:reply, state.llm, state}
  end

  defp setup_llm(opts) do
    model = Keyword.get(opts, :model, "gpt-3.5-turbo")
    api_key = get_api_key()

    LangChain.ChatModels.ChatOpenAI.new!(%{
      model: model,
      api_key: api_key,
      temperature: 0.7,
      request_timeout: 30_000
    })
  end

  defp get_api_key do
    System.get_env("OPENAI_API_KEY") ||
      raise "Environment variable OPENAI_API_KEY is not set"
  end
end
