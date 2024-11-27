# Mix.install([
#   {:whisperer, path: "."}
# ])

# Ensure the application and all its dependencies are started
{:ok, _} = Application.ensure_all_started(:whisperer)

# Add an agent to a session's orchestrator
:ok = Whisperer.Orchestrator.add_agent("session456", Whisperer.Agents.TechAgent)

# Process a message in that session
case Whisperer.Orchestrator.process_message(
  "How do I implement a binary search tree in Elixir?",
  "user123",
  "session456"
) do
  {:ok, response} -> IO.puts(response)
  {:error, error} -> IO.puts("Error: #{inspect(error)}")
end

# Get conversation history for the session
history = Whisperer.Orchestrator.get_conversation("user123", "session456")
IO.inspect(history, label: "Conversation History")

# You can have multiple sessions with their own orchestrators
:ok = Whisperer.Orchestrator.add_agent("another_session", Whisperer.Agents.TechAgent)
