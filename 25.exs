defmodule TwentyFive do
  # ran in 200s
  def part_one(input) do
    map = parse(input)

    node_pairs =
      Map.keys(map)
      |> then(fn nodes -> for a <- nodes, b <- nodes, a != b, into: MapSet.new(), do: Enum.sort([a, b]) end)

    Enum.reduce(1..100, %{}, fn i, acc ->
      IO.inspect(i)
      node_pairs
      |> Enum.shuffle()
      |> Enum.take(10)
      |> Enum.reduce(acc, fn nodes, acc2 ->
        shortest_path(nodes, map)
        |> Enum.reduce(acc2, fn pair, acc3 ->
          Map.update(acc3, pair, 1, &(&1 + 1))
        end)
      end)
    end)
    |> Enum.sort_by(&elem(&1, 1), &>/2)
    |> Enum.take(3)
    |> Enum.map(&elem(&1, 0))
    |> then(fn [[a, b] | _] = pairs ->
      snipped = map_remove_pairs(map, pairs)
      group_size(a, snipped) * group_size(b, snipped)
    end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.reduce(%{}, fn line, acc ->
      [a | rest] = String.split(line, [": ", " "])
      rest
      |> Enum.reduce(acc, fn b, acc2 ->
        Map.update(acc2, b, MapSet.new([a]), fn set -> MapSet.put(set, a) end)
      end)
      |> Map.update(a, MapSet.new(rest), fn set -> rest |> MapSet.new() |> MapSet.union(set) end)
    end)
  end

  defp map_remove_pairs(map, []), do: map
  defp map_remove_pairs(map, [[a, b] | rest]) do
    new_map =
      map
      |> Map.update!(a, &MapSet.delete(&1, b))
      |> Map.update!(b, &MapSet.delete(&1, a))
    map_remove_pairs(new_map, rest)
  end

  def group_size(node, map), do: group_size([node], map, MapSet.new())
  defp group_size([], _, seen), do: MapSet.size(seen)
  defp group_size([node | rest], map, seen) do
    nexts = MapSet.difference(map[node], seen) |> Enum.to_list()
    group_size(nexts ++ rest, map, MapSet.put(seen, node))
  end

  defp shortest_path([a, b], map), do: shortest_path(map[a] |> Enum.map(&({&1, [Enum.sort([a, &1])]})), [], b, MapSet.new([a]), map)
  defp shortest_path([{dest, path} | _], _, dest, _, _), do: path
  defp shortest_path([], nexts, dest, seen, map), do: shortest_path(nexts, [], dest, seen, map)
  defp shortest_path([{node, path} | rest], nexts, dest, seen, map) do
    new_nexts = map[node]
      |> MapSet.difference(seen)
      |> Enum.map(fn next -> {next, [Enum.sort([node, next]) | path]} end)
    shortest_path(rest, new_nexts ++ nexts, dest, MapSet.union(seen, map[node]), map)
  end
end

input = File.read!("input/25.txt")

input |> TwentyFive.part_one() |> IO.inspect(label: "part 1")
