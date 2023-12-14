defmodule Fourteen do
  def part_one(input) do
    input
    |> parse()
    |> tilt(:north)
    |> calculate_load()
  end

  def part_two(input) do
    input
    |> parse()
    |> spin_times(1_000_000_000)
    |> calculate_load()
  end

  defp parse(text) do
    {rocks, cubes} =
      text
      |> String.trim()
      |> String.split(~r/\R/)
      |> Enum.with_index()
      |> Enum.reduce({MapSet.new(), MapSet.new()}, fn {line, y}, acc ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(acc, fn
          {"O", x}, {rocks, cubes} -> {MapSet.put(rocks, {x, y}), cubes}
          {"#", x}, {rocks, cubes} -> {rocks, MapSet.put(cubes, {x, y})}
          _, acc2 -> acc2
        end)
      end)
    max_x =
      text
      |> String.trim()
      |> String.split(~r/\R/)
      |> List.first()
      |> String.length()
      |> Kernel.-(1)
    max_y =
      text
      |> String.trim()
      |> String.split(~r/\R/)
      |> length()
      |> Kernel.-(1)

    {rocks, cubes, max_x, max_y}
  end

  defp tilt({rocks, cubes, max_x, max_y}, :north) do
    new_rocks =
      Enum.reduce(1..max_y, rocks, fn row, acc ->
        objects = acc |> MapSet.new() |> MapSet.union(cubes)
        Enum.map(acc, fn
          {x, y} when y != row -> {x, y}
          {x, y} ->
            case Enum.find((y - 1)..0, &MapSet.member?(objects, {x, &1})) do
              nil -> {x, 0}
              obj_y -> {x, obj_y + 1}
            end
        end)
      end)
      |> MapSet.new()
    {new_rocks, cubes, max_x, max_y}
  end

  defp tilt({rocks, cubes, max_x, max_y}, :west) do
    new_rocks =
      Enum.reduce(1..max_x, rocks, fn col, acc ->
        objects = acc |> MapSet.new() |> MapSet.union(cubes)
        Enum.map(acc, fn
          {x, y} when x != col -> {x, y}
          {x, y} ->
            case Enum.find((x - 1)..0, &MapSet.member?(objects, {&1, y})) do
              nil -> {0, y}
              obj_x -> {obj_x + 1, y}
            end
        end)
      end)
      |> MapSet.new()
    {new_rocks, cubes, max_x, max_y}
  end

  defp tilt({rocks, cubes, max_x, max_y}, :south) do
    new_rocks =
      Enum.reduce((max_y - 1)..0, rocks, fn row, acc ->
        objects = acc |> MapSet.new() |> MapSet.union(cubes)
        Enum.map(acc, fn
          {x, y} when y != row -> {x, y}
          {x, y} ->
            case Enum.find((y + 1)..max_y, &MapSet.member?(objects, {x, &1})) do
              nil -> {x, max_y}
              obj_y -> {x, obj_y - 1}
            end
        end)
      end)
      |> MapSet.new()
    {new_rocks, cubes, max_x, max_y}
  end

  defp tilt({rocks, cubes, max_x, max_y}, :east) do
    new_rocks =
      Enum.reduce((max_x - 1)..0, rocks, fn col, acc ->
        objects = acc |> MapSet.new() |> MapSet.union(cubes)
        Enum.map(acc, fn
          {x, y} when x != col -> {x, y}
          {x, y} ->
            case Enum.find((x + 1)..max_x, &MapSet.member?(objects, {&1, y})) do
              nil -> {max_x, y}
              obj_x -> {obj_x - 1, y}
            end
        end)
      end)
      |> MapSet.new()
    {new_rocks, cubes, max_x, max_y}
  end

  defp spin(state) do
    state
    |> tilt(:north)
    |> tilt(:west)
    |> tilt(:south)
    |> tilt(:east)
  end

  defp spin_times(state, times) do
    {cycle_state, cycle_start, cycle_t} = find_cycle(state)
    more_times = (times - cycle_start) - (div((times - cycle_start), cycle_t) * cycle_t)

    Stream.iterate(cycle_state, &spin/1)
    |> Enum.at(more_times)
  end

  defp find_cycle(state), do: find_cycle(state, 0, %{})
  defp find_cycle({rocks, _, _, _} = state, i, memo) do
    case Map.get(memo, rocks) do
      nil ->
        new_state = spin(state)
        find_cycle(new_state, i + 1, Map.put(memo, rocks, i))
      cycle_start -> {state, cycle_start, i - cycle_start}
    end
  end

  defp calculate_load({rocks, _, _, max_y}) do
    rocks
    |> Enum.map(fn {_, y} -> max_y + 1 - y end)
    |> Enum.sum()
  end
end

input = File.read!("input/14.txt")

input |> Fourteen.part_one() |> IO.inspect(label: "part 1")
input |> Fourteen.part_two() |> IO.inspect(label: "part 2")
