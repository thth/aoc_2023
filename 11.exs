defmodule Eleven do
  def part_one(input) do
    input
    |> parse()
    |> expand(1)
    |> pairs()
    |> Enum.map(&manhattan_distance/1)
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> expand(1_000_000 - 1)
    |> pairs()
    |> Enum.map(&manhattan_distance/1)
    |> Enum.sum()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.with_index()
    |> Enum.reduce([], fn {line, y}, acc ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn
        {".", _}, line_acc -> line_acc
        {"#", x}, line_acc -> [{x, y} | line_acc]
      end)
    end)
  end

  defp expand(universe, d) do
    universe
    |> expand_x(d)
    |> expand_y(d)
    |> Enum.sort()
  end

  defp expand_x(universe, d) do
    {max_x, _} = Enum.max_by(universe, fn {x, _} -> x end)
    expand_x(universe, 0, max_x, d)
  end
  defp expand_x(universe, x, max_x, _) when x > max_x, do: universe
  defp expand_x(universe, x, max_x, d) do
    if Enum.any?(universe, fn {tile_x, _} -> tile_x == x end) do
      expand_x(universe, x + 1, max_x, d)
    else
      new_universe = Enum.map(universe, fn
        {tx, ty} when tx > x -> {tx + d, ty}
        tile -> tile
      end)

      expand_x(new_universe, x + d + 1, max_x + d, d)
    end
  end

  defp expand_y(universe, d) do
    {_, max_y} = Enum.max_by(universe, fn {_, y} -> y end)
    expand_y(universe, 0, max_y, d)
  end
  defp expand_y(universe, y, max_y, _) when y > max_y, do: universe
  defp expand_y(universe, y, max_y, d) do
    if Enum.any?(universe, fn {_, tile_y} -> tile_y == y end) do
      expand_y(universe, y + 1, max_y, d)
    else
      new_universe = Enum.map(universe, fn
        {tx, ty} when ty > y -> {tx, ty + d}
        tile -> tile
      end)

      expand_y(new_universe, y + d + 1, max_y + d, d)
    end
  end

  defp pairs(galaxies) do
    Enum.reduce(galaxies, {[], Enum.slice(galaxies, 1..-1)}, fn
      g, {acc, [_| rest] = remaining} ->
        additions = for h <- remaining, do: {g, h}
        {additions ++ acc, rest}
      _, {acc, _} -> acc
    end)
  end

  defp manhattan_distance({{x1, y1}, {x2, y2}}) do
    abs(x2 - x1) + abs(y2 - y1)
  end
end

input = File.read!("input/11.txt")

input |> Eleven.part_one() |> IO.inspect(label: "part 1")
input |> Eleven.part_two() |> IO.inspect(label: "part 2")
