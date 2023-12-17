defmodule Seventeen do
  def part_one(input) do
    input
    |> parse()
    |> search(:crucible)
  end

  def part_two(input) do
    input
    |> parse()
    |> search(:ultra_crucible)
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
      |> Enum.reduce(acc, fn {n, x}, map -> Map.put(map, {x, y}, String.to_integer(n)) end)
    end)
    |> then(fn map ->
      {{max_x, _}, _} = Enum.max_by(map, fn {{x, _}, _} -> x end)
      {{_, max_y}, _} = Enum.max_by(map, fn {{_, y}, _} -> y end)
      {map, max_x, max_y}
    end)
  end

  defp search(map_info, type), do: search([{{1, 0, :e}, {1, 0}}, {{0, 1, :s}, {1, 0}}], [], map_info, %{}, type)
  defp search([], [], {_, max_x, max_y}, memo, type) do
    memo
    |> Enum.filter(fn {{x, y, _dir}, _} -> x == max_x and y == max_y end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.map(fn heats ->
      case type do
        :crucible -> heats
        :ultra_crucible -> Enum.slice(heats, 3..-1)
      end
    end)
    |> List.flatten()
    |> Enum.min()
  end
  defp search([], next, map_info, memo, type), do: search(next, [], map_info, memo, type)
  defp search([{{x, y, dir}, {steps, path_heat}} | rest], next, {map, max_x, max_y}, memo, type) do
    tile_heat = map[{x, y}]
    current_path = {{x, y, dir}, {steps, path_heat + tile_heat}}
    case improvement?(current_path, memo, type) do
      false -> search(rest, next, {map, max_x, max_y}, memo, type)
      new_memo -> search(rest, new_paths(current_path, max_x, max_y, type) ++ next, {map, max_x, max_y}, new_memo, type)
    end
  end

  defp improvement?({coords, {steps, heat}}, memo, type) do
    with {:ok, seen} <- Map.fetch(memo, coords),
         improvement <- try_improve(steps, heat, seen),
         true <- improvement != seen do
      Map.put(memo, coords, improvement)
    else
      :error ->
        l = (if type == :crucible, do: 3, else: 10)
        Map.put(memo, coords, List.duplicate(nil, l) |> List.replace_at(steps - 1, heat))
      false -> false
    end
  end

  defp try_improve(steps, heat, seen), do: List.update_at(seen, steps - 1, fn s ->  min(heat, s) end)

  defp new_paths({{x, y, dir}, {steps, h}}, max_x, max_y, type) do
    case dir do
      :n -> [{{x - 1, y, :w}, {1, h}}, {{x, y - 1, :n}, {steps + 1, h}}, {{x + 1, y, :e}, {1, h}}]
      :s -> [{{x - 1, y, :w}, {1, h}}, {{x, y + 1, :s}, {steps + 1, h}}, {{x + 1, y, :e}, {1, h}}]
      :w -> [{{x, y - 1, :n}, {1, h}}, {{x - 1, y, :w}, {steps + 1, h}}, {{x, y + 1, :s}, {1, h}}]
      :e -> [{{x, y - 1, :n}, {1, h}}, {{x + 1, y, :e}, {steps + 1, h}}, {{x, y + 1, :s}, {1, h}}]
    end
    |> then(fn paths ->
      case type do
        :crucible ->
          Enum.reject(paths, fn {{x, y, _d}, {new_steps, _h}} ->
            x < 0 or y < 0 or x > max_x or y > max_y
            or new_steps > 3
          end)
        :ultra_crucible ->
          Enum.reject(paths, fn {{x, y, d}, {new_steps, _h}} ->
            x < 0 or y < 0 or x > max_x or y > max_y
            or (d != dir and steps < 4)
            or new_steps > 10
          end)
      end
    end)
  end
end

input = File.read!("input/17.txt")

input |> Seventeen.part_one() |> IO.inspect(label: "part 1")
input |> Seventeen.part_two() |> IO.inspect(label: "part 2")
