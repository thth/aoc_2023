defmodule Three do
  def part_one(input) do
    input
    |> parse()
    |> find_parts()
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> find_gears()
    |> Map.values()
    |> Enum.filter(fn numbers -> length(numbers) == 2 end)
    |> Enum.map(&Enum.product/1)
    |> Enum.sum()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.with_index()
    |> Enum.reduce({[], %{}}, fn {line, y}, {numbers, map} ->
      new_numbers =
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.chunk_by(fn {char, _x} -> char =~ ~r/\d/ end)
        |> Enum.filter(fn [{char, _x}| _rest] -> char =~ ~r/\d/ end)
        |> Enum.map(fn group = [{_, x} | _rest]->
          n =
            group
            |> Enum.map(fn {d, _x} -> d end)
            |> Enum.join()
            |> String.to_integer()
          {n, length(group), {x, y}}
        end)
        |> Kernel.++(numbers)
      new_map =
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(map, fn
          {".", _}, acc -> acc
          {char, x}, acc -> Map.put(acc, {x, y}, char)
        end)
      {new_numbers, new_map}
    end)
  end

  defp find_parts({numbers, map}), do: find_parts(numbers, map, [])
  defp find_parts([], _map, parts), do: parts
  defp find_parts([{number, length, coords} | rest], map, parts) do
    if adj_symbol?(coords, length, map) do
      find_parts(rest, map, [number | parts])
    else
      find_parts(rest, map, parts)
    end
  end

  defp adj_symbol?({x, y}, length, map) do
    to_check = for a <- (x-1)..(x+length), b <- (y-1)..(y+1), do: {a, b}
    Enum.any?(to_check, fn coords ->
      if map[coords] == nil do
        false
      else
        map[coords] != "." and not (map[coords] =~ ~r/\d/)
      end
    end)
  end

  defp find_gears({numbers, map}), do: find_gears(numbers, map, %{})
  defp find_gears([], _map, gears), do: gears
  defp find_gears([{number, length, coords} | rest], map, gears) do
    case adj_gears(coords, length, map) do
      [] -> find_gears(rest, map, gears)
      adjs ->
        new_gears =
          Enum.reduce(adjs, gears, fn adj, acc ->
            Map.update(acc, adj, [number], fn nums -> [number | nums] end)
          end)
        find_gears(rest, map, new_gears)
    end
  end

  defp adj_gears({x, y}, length, map) do
    to_check = for a <- (x-1)..(x+length), b <- (y-1)..(y+1), do: {a, b}
    Enum.filter(to_check, fn coords -> map[coords] == "*" end)
  end
end

input = File.read!("input/03.txt")

input |> Three.part_one() |> IO.inspect(label: "part 1")
input |> Three.part_two() |> IO.inspect(label: "part 2")
