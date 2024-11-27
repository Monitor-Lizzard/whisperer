defmodule Whisperer.Agents.TechAgent do
  @behaviour Whisperer.Agent
  alias Whisperer.Langchain.Client

  @impl true
  def characteristics do
    %{
      id: "tech_agent",
      name: "Tech Agent",
      description: "Specializes in technology areas including software development, hardware, AI, and cybersecurity",
      capabilities: ["software", "hardware", "ai", "cybersecurity"]
    }
  end

  @impl true
  def process_message(message, _user_id, _session_id, context) do
    conversation_history = context.conversation_history
    history_context = format_conversation_history(conversation_history)

    prompt = """
    Previous conversation:
    #{history_context}

    You are a technical expert. Please respond to the following query:
    #{message}
    """

    Client.generate(prompt)
  end

  defp format_conversation_history([]), do: "No previous conversation"
  defp format_conversation_history(history) do
    history
    |> Enum.map_join("\n", fn msg ->
      "#{msg.role}: #{msg.content}"
    end)
  end
end
