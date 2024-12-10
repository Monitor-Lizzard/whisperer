# Whisperer

[![Actions Status](https://github.com/monitor-lizzard/whisperer/workflows/CI/badge.svg)](https://github.com/Monitor-Lizzard/whisperer/actions?query=workflow:CI) [![Hex.pm](https://img.shields.io/hexpm/v/whisperer.svg)](https://hex.pm/packages/whisperer) [![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/whisperer)


**Whisperer is an unopionated multi-agent framework in Elixir**

## Features
- **No-batteries-included**: With Whisperer, you can build your own agents with any implementations and logic you want
- **Resilient orchestration**: Whisperer orchestrates and manages the lifecycle of your agents using battle-tested OTP strategies
- **Scalable**: Whisperer is built on top of Elixir's OTP, which means it can scale to millions of agents with ease
- **Fault-tolerant**: Whisperer is built to be fault-tolerant, meaning that it can recover from failures and continue to operate

##  Workflow Structure

![Workflow Struture](https://raw.githubusercontent.com/Monitor-Lizzard/whisperer/main/img/flow.png)

## Key Components 

### Orchestrator
The Orchestrator is the main component of Whisperer. It is responsible for managing the lifecycle of agents and orchestrating the communication between them. The Orchestrator is the entry point for all agents and is responsible for starting, stopping, and monitoring agents.

### Agent
An Agent is a worker that performs a specific task. Agents can be implemented in any way you want, as long as they implement the `Whisperer.Agent` behaviour. Agents can communicate with each other using messages.

### Message
A Message is a data structure that is sent between agents. Messages can contain any data you want, as long as it is serializable. Messages are used to communicate between agents and the Orchestrator.

### Sequence
A Sequence is a collection of agents that are executed in a specific order. Sequences can be used to model complex workflows and orchestrate the work of multiple agents.

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `whisperer` to your list of dependencies in `mix.exs`

## Usage

`1. Implement a Sequencer`
```elixir
defmodule MultiAgentDemo.Simple.Sequencer do
  @moduledoc false

  alias Whisperer.Sequence
  @behaviour Whisperer.Sequencer

  @impl true
  def create_sequence(_content, _characteristics, _conversation_history) do
    {:ok,
     %Sequence{
       start_agent: "bracket",
       connections: %{
         "bracket" => ["division"],
         "division" => ["multiplication"],
         "multiplication" => ["addition"],
         "addition" => ["subtraction"]
       }
     }}
  end
end
```

`2: Initialize the Workflow`
```elixir
{:ok, _} = Whisperer.start_session(session_id, MultiAgentDemo.Simple.Sequencer, %{})
```
`3: Implement agents`
```elixir
defmodule MultiAgentDemo.Simple.Agents.Division do
  @moduledoc false

  @agent_id "division"

  @behaviour Whisperer.Agent

  @impl true
  def characteristics do
    %{
      id: @agent_id,
      name: "Division Agent",
      description: "Specializes in dividing numbers",
      capabilities: ["math", "division"]
    }
  end

  @impl true
  def process_message(%_{content: content}, _context, _conversation_history) do
    with result <- solve_division(content) do
      {:ok, %Whisperer.Message{content: result, agent_id: @agent_id, role: :assistant}}
    end
  end
end
```
`4: Add implemented agents to the workflow`
```elixir
Whisperer.add_agent(session_id, MultiAgentDemo.Simple.Agents.Division)
```
`5: Evaluate User Input`
```elixir
Whisperer.process_user_input(session_id, content)
```

## Demos

A demo app for the BODMAS mathematics problem containing two implementations, an algorithmic implementation and an LLM implementation has been created [here](https://github.com/Monitor-Lizzard/multiagent-demo)

```elixir
def deps do
  [
    {:whisperer, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/whisperer>.

