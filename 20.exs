defmodule Twenty do
  def part_one(input) do
    input
    |> parse()
    |> then(&({&1, 0, 0}))
    |> Stream.iterate(&run/1)
    |> Enum.at(1_000)
    |> then(fn {_, highs, lows} -> highs * lows end)
  end

  # やりたくない～
  def part_two(input) do
    input
    |> parse()
    |> Map.put("rx", %{name: "rx", received_low?: false})
    |> then(&({&1, 0, 0}))
    |> Stream.iterate(&run/1)
    |> Enum.find_index(fn {states, _, _} -> states["rx"][:received_low?] == true end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      [module | outputs] = String.split(line, [" -> ", ", "])
      case module do
        "broadcaster" -> {"broadcaster", %{name: "broadcaster", outputs: outputs}}
        "%" <> name -> {name, %{name: name, outputs: outputs, type: "%", mem: :off}}
        "&" <> name -> {name, %{name: name, outputs: outputs, type: "&", mem: %{}}}
      end
    end)
    |> Enum.into(%{})
    |> then(fn map ->
      modules = Map.keys(map)
      Enum.reduce(map, map, fn {name, %{outputs: outputs}}, acc ->
        Enum.reduce(outputs, acc, fn output, acc2 ->
          if output in modules do
            Map.update!(acc2, output, fn
              %{type: "&"} = state -> Map.update!(state, :mem, &Map.put(&1, name, :low))
              module -> module
            end)
          else
            acc2
          end
        end)
      end)
    end)
  end

  defp run(status), do: run([{"broadcaster", "button", :low}], status)
  defp run([], status), do: status
  defp run([{target, origin, pulse} | rest], {states, lows, highs}) do
    {new_lows, new_highs} = case pulse do
      :low -> {lows + 1, highs}
      :high -> {lows, highs + 1}
    end
    {new_pulses, new_states} = process(states[target], origin, pulse, states)
    run(rest ++ new_pulses, {new_states, new_lows, new_highs})
  end

  defp process(%{name: "broadcaster", outputs: outputs}, _, pulse, states) do
    {Enum.map(outputs, &({&1, "broadcaster", pulse})), states}
  end
  defp process(%{type: "%"}, _, :high, states), do: {[], states}
  defp process(%{type: "%", name: name, mem: :off, outputs: outputs}, _, :low, states) do
    new_pulses = Enum.map(outputs, &({&1, name, :high}))
    new_states = Map.update!(states, name, fn state -> %{state | mem: :on} end)
    {new_pulses, new_states}
  end
  defp process(%{type: "%", name: name, mem: :on, outputs: outputs}, _, :low, states) do
    new_pulses = Enum.map(outputs, &({&1, name, :low}))
    new_states = Map.update!(states, name, fn state -> %{state | mem: :off} end)
    {new_pulses, new_states}
  end
  defp process(%{type: "&", name: name, mem: mem, outputs: outputs}, origin, pulse, states) do
    new_mem = Map.put(mem, origin, pulse)
    out = if Enum.all?(new_mem, fn {_, p} -> p == :high end), do: :low, else: :high
    new_pulses = Enum.map(outputs, &({&1, name, out}))
    new_states = Map.update!(states, name, fn state -> %{state | mem: new_mem} end)
    {new_pulses, new_states}
  end
  defp process(%{name: "rx"}, _, :low, states) do
    {[], Map.update!(states, "rx", fn state -> %{state | received_low?: true} end)}
  end
  defp process(_, _, _, states), do: {[], states}

end

input = File.read!("input/20.txt")
# input = File.read!("input/_test.txt")

input |> Twenty.part_one() |> IO.inspect(label: "part 1")
input |> Twenty.part_two() |> IO.inspect(label: "part 2")
