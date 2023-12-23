defmodule TwentyThree do
  def part_one(input) do
    input
    |> parse()
    |> walk()
  end

  def part_two(input) do
    input
    |> parse()
    |> then(fn {map, start, finish} ->
      {Enum.map(map, fn {pos, _} -> {pos, "."} end) |> Enum.into(%{}), start, finish}
    end)
    |> walk()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, y}, acc ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn
        {"#", _}, acc2 -> acc2
        {c, x}, acc2 -> Map.put(acc2, {x, y}, c)
      end)
    end)
    |> then(fn map ->
      {start, finish} = map |> Map.keys() |> Enum.min_max_by(&elem(&1, 1))
      {map, start, finish}
    end)
  end

  defp walk({map, start, finish}), do: walk([{start, MapSet.new(), 0}], finish, map, 0)
  defp walk([], _, _, longest), do: longest
  defp walk([{finish, _, steps} | rest], finish, map, longest), do: walk(rest, finish, map, max(steps, longest))
  defp walk([{{x, y}, been, steps} | rest], finish, map, longest) do
    cond do
      MapSet.member?(been, {x, y}) -> walk(rest, finish, map, longest)
      map[{x, y}] == "^" -> walk([{{x, y - 1}, MapSet.put(been, {x, y}), steps + 1} | rest], finish, map, longest)
      map[{x, y}] == "v" -> walk([{{x, y + 1}, MapSet.put(been, {x, y}), steps + 1} | rest], finish, map, longest)
      map[{x, y}] == "<" -> walk([{{x - 1, y}, MapSet.put(been, {x, y}), steps + 1} | rest], finish, map, longest)
      map[{x, y}] == ">" -> walk([{{x + 1, y}, MapSet.put(been, {x, y}), steps + 1} | rest], finish, map, longest)
      map[{x, y}] == "." ->
        nexts =
          next_poses({x, y}, map, been)
          |> Enum.map(fn pos -> {pos, MapSet.put(been, {x, y}), steps + 1} end)
        walk(nexts ++ rest, finish, map, longest)
    end
  end

  defp next_poses({x, y}, map, been) do
    [{x, y - 1}, {x, y + 1}, {x - 1, y}, {x + 1, y}]
    |> Enum.filter(fn pos -> Map.has_key?(map, pos) and not MapSet.member?(been, pos) end)
  end
end

input = File.read!("input/23.txt")

input |> TwentyThree.part_one() |> IO.inspect(label: "part 1")
input |> TwentyThree.part_two() |> IO.inspect(label: "part 2")
