defmodule Whisperer.Classifier do
  @moduledoc """
  Handles classification of user input to determine the most appropriate agent.
  """

  alias Whisperer.{Agent, Langchain.Client}

  @type classification_result :: {Agent.agent_id(), float()}

  @doc """
  Classifies the input message and returns the most suitable agent ID.
  Uses LangChain to analyze the message against agent characteristics and conversation history.
  """
  @spec classify(String.t(), Agent.user_id(), Agent.session_id(), [map()], [Agent.agent_characteristics()]) ::
    {:ok, Agent.agent_id()} | {:error, term()}
  def classify(message, _user_id, _session_id, conversation_history, agents_characteristics) do
    # Prepare the prompt for the LLM
    prompt = build_classification_prompt(message, agents_characteristics, conversation_history)

    # Use LangChain to get classification
    case Client.generate(prompt) do
      {:ok, classification_result} ->
        parse_classification_result(classification_result)
      error ->
        error
    end
  end

  defp build_classification_prompt(message, agents_characteristics, conversation_history) do
    agents_desc = Enum.map_join(agents_characteristics, "\n", fn char ->
      "Agent: #{char.name}\nDescription: #{char.description}\nCapabilities: #{Enum.join(char.capabilities, ", ")}"
    end)

    history_context = format_conversation_history(conversation_history)

    """
    Given the following agents and conversation history, determine the most appropriate agent to handle this user message.

    Available Agents:
    #{agents_desc}

    Conversation History:
    #{history_context}

    User Message: #{message}

    Respond with only the ID of the most appropriate agent.
    """
  end

  defp format_conversation_history(history) do
    Enum.map_join(history, "\n", fn msg ->
      "#{msg.role}: #{msg.content}"
    end)
  end

  defp parse_classification_result(result) do
    # Extract agent ID from LLM response
    case String.trim(result) do
      "" -> {:error, :invalid_classification}
      agent_id -> {:ok, agent_id}
    end
  end
end
