defmodule Eighteen do
  def part_one(input) do
    input
    |> parse()
    |> run()
    |> fill()
    |> Enum.count()
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.map(&convert/1)
    |> run()
    |> fill()
    |> Enum.count()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      [dir, steps, colour] = String.split(line, " ")
      {dir, String.to_integer(steps), String.slice(colour, 1..-2)}
    end)
  end

  defp run(instructions), do: run(instructions, {0, 0}, MapSet.new([{0, 0}]))
  defp run([], _pos, map), do: map
  defp run([ins | rest], pos, map) do
    {new_pos, holes} = dig(pos, ins)
    run(rest, new_pos, MapSet.union(map, holes))
  end

  defp dig({x, y}, {"U", steps, _c}), do: {{x, y-steps}, (for j <- (y-1)..(y-steps), into: MapSet.new(), do: {x, j})}
  defp dig({x, y}, {"D", steps, _c}), do: {{x, y+steps}, (for j <- (y+1)..(y+steps), into: MapSet.new(), do: {x, j})}
  defp dig({x, y}, {"L", steps, _c}), do: {{x-steps, y}, (for i <- (x-1)..(x-steps), into: MapSet.new(), do: {i, y})}
  defp dig({x, y}, {"R", steps, _c}), do: {{x+steps, y}, (for i <- (x+1)..(x+steps), into: MapSet.new(), do: {i, y})}

  defp fill(holes) do
    {{min_x, _}, {max_x, _}} = Enum.min_max_by(holes, &elem(&1, 0))
    {{_, min_y}, {_, max_y}} = Enum.min_max_by(holes, &elem(&1, 1))
    outsides = outside([{-1, -1}], [], MapSet.new(), {min_x..max_x, min_y..max_y}, holes)
    (for x <- min_x..max_x, y <- min_y..max_y, into: MapSet.new(), do: {x, y})
    |> MapSet.difference(outsides)
  end

  defp outside([], [], seen, _, _), do: seen
  defp outside([], next, seen, ranges, holes), do: outside(next, [], seen, ranges, holes)
  defp outside([{x, y} | rest], next, seen, ranges, holes) do
    if next_outside?({x, y}, seen, ranges, holes) do
      outside(rest, [{x-1,y},{x+1,y},{x,y-1},{x,y+1}] ++ next, MapSet.put(seen, {x, y}), ranges, holes)
    else
      outside(rest, next, seen, ranges, holes)
    end
  end

  defp next_outside?({x, y}, _, {min_x..max_x, min_y..max_y}, _)
    when x < (min_x-1) or y < (min_y-1) or x > (max_x+1) or y > (max_y+1), do: false
  defp next_outside?(pos, seen, _, holes) do
    not (MapSet.member?(seen, pos) or MapSet.member?(holes, pos))
  end

  defp convert({_, _, <<"#", s::binary-size(5), d>>}) do
    dir =
      case d do
        ?0 -> "R"
        ?1 -> "D"
        ?2 -> "L"
        ?3 -> "U"
      end
    steps = String.to_integer(s, 16)
    {dir, steps, nil}
  end
end

input = File.read!("input/18.txt")
# input = File.read!("input/_test.txt")

# input |> Eighteen.part_one() |> IO.inspect(label: "part 1")
input |> Eighteen.part_two() |> IO.inspect(label: "part 2")
