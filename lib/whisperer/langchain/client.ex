defmodule Whisperer.Langchain.Client do
  @moduledoc """
  Client module for interacting with LangChain LLMs.
  """

  alias Whisperer.Langchain.Config

  @doc """
  Generates a response from the LLM using the given prompt.
  """
  @spec generate(String.t()) :: {:ok, String.t()} | {:error, term()}
  def generate(prompt) do
    llm = Config.get_llm()

    try do
      messages = [
        %{role: "user", content: prompt}
      ]

      case LangChain.ChatModels.ChatOpenAI.call(llm, messages) do
        {:ok, %{content: content}} ->
          {:ok, content}
        {:error, reason} ->
          {:error, reason}
        error ->
          {:error, error}
      end
    rescue
      e -> {:error, e}
    end
  end
end
