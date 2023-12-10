defmodule Ten do
  def part_one(input) do
    map = parse(input)
    {start, _} = Enum.find(map, fn {_, tile} -> tile == "S" end)
    {_, farthest} = loop(start, map)

    farthest
  end

  def part_two(input) do
    map = parse(input)
    {start, _} = Enum.find(map, fn {_, tile} -> tile == "S" end)
    {loop_tiles, _} = loop(start, map)
    {max_x, _} = Map.keys(map) |> Enum.max_by(fn {x, _} -> x end)
    {_, max_y} = Map.keys(map) |> Enum.max_by(fn {_, y} -> y end)
    roomy_max_x = max_x * 2
    roomy_max_y = max_y * 2
    bx1 = for x <- -1..(roomy_max_x + 1), do: {x, -1}
    bx2 = for x <- -1..(roomy_max_x + 1), do: {x, roomy_max_y + 1}
    by1 = for y <- -1..(roomy_max_y + 1), do: {-1, y}
    by2 = for y <- -1..(roomy_max_y + 1), do: {roomy_max_x + 1, y}
    border = MapSet.new(bx1 ++ bx2 ++ by1 ++ by2) |> Enum.to_list()
    roomy_loop =
      loop_tiles
      |> Enum.map(fn {x, y} -> {x * 2, y * 2} end)
      |> MapSet.new()
      |> then(fn tiles ->
        Enum.reduce(tiles, tiles, fn {x, y}, acc ->
          {div(x, 2), div(y, 2)}
          |> connections({x, y}, map)
          |> MapSet.new()
          |> MapSet.union(acc)
        end)
      end)
    n_outside = count_outside(border, [], roomy_loop, roomy_max_x, roomy_max_y, MapSet.new())
    ((max_x + 1) * (max_y + 1)) - n_outside - MapSet.size(loop_tiles)
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
      |> Enum.reduce(acc, fn {c, x}, line_acc ->
        Map.put(line_acc, {x, y}, c)
      end)
    end)
  end

  defp loop({sx, sy}, map) do
    next =
      [
        (if map[{sx, sy-1}] in ~w[| 7 F], do: {sx, sy-1}, else: nil),
        (if map[{sx, sy+1}] in ~w[| J L], do: {sx, sy+1}, else: nil),
        (if map[{sx-1, sy}] in ~w[- L F], do: {sx-1, sy}, else: nil),
        (if map[{sx+1, sy}] in ~w[- 7 J], do: {sx+1, sy}, else: nil),
      ]
      |> Enum.reject(&is_nil/1)
    loop([], next, MapSet.new([{sx, sy}]), 0, map)
  end

  defp loop([], [], been, steps, _map), do: {been, steps}
  defp loop([], next, been, steps, map), do: loop(next, [], been, steps + 1, map)
  defp loop([tile | rest], next, been, steps, map) do
    new_next = Enum.reject(connections(tile, map), &MapSet.member?(been, &1)) ++ next
    loop(rest, new_next, MapSet.put(been, tile), steps, map)
  end

  defp connections(tile, map), do: connections(tile, tile, map)
  defp connections(tile, {x, y}, map) do
    case map[tile] do
      "-" -> [{x-1, y}, {x+1, y}]
      "|" -> [{x, y-1}, {x, y+1}]
      "J" -> [{x, y-1}, {x-1, y}]
      "L" -> [{x, y-1}, {x+1, y}]
      "7" -> [{x, y+1}, {x-1, y}]
      "F" -> [{x, y+1}, {x+1, y}]
      "S" -> []
    end
  end

  defp count_outside([], [], _, _, _, outsides) do
    outsides
    |> Enum.filter(fn {x, y} -> rem(x, 2) == 0 and rem(y, 2) == 0 end)
    |> Enum.count()
  end
  defp count_outside([], next, forbidden, max_x, max_y, outsides),
    do: count_outside(next, [], forbidden, max_x, max_y, outsides)
  defp count_outside([tile | rest], next, forbidden, max_x, max_y, outsides) do
    news = outside_adjs(tile, forbidden, max_x, max_y)
    new_forbidden = MapSet.new(news) |> MapSet.union(forbidden)
    new_outsides = MapSet.new(news) |> MapSet.union(outsides)
    count_outside(rest, news ++ next, new_forbidden, max_x, max_y, new_outsides)
  end

  defp outside_adjs({x, y}, forbidden, max_x, max_y) do
    for {a, b} <- [{x, y-1}, {x, y+1}, {x-1, y}, {x+1, y}],
        a >= 0,
        a <= max_x,
        b >= 0,
        b <= max_y do
      {a, b}
    end
    |> Enum.reject(&MapSet.member?(forbidden, &1))
  end
end

input = File.read!("input/10.txt")

input |> Ten.part_one() |> IO.inspect(label: "part 1")
input |> Ten.part_two() |> IO.inspect(label: "part 2")
