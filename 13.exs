defmodule Thirteen do
  def part_one(input) do
    input
    |> parse()
    |> Enum.map(&find_reflection/1)
    |> Enum.map(&Enum.at(&1, 0))
    |> Enum.reduce(0, fn
      {:x, n, _}, acc -> acc + n
      {:y, n, _}, acc -> acc + (100 * n)
    end)
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.map(&find_reflection/1)
    |> Enum.map(&Enum.at(&1, 1))
    |> Enum.reduce(0, fn
      {:x, n, _}, acc -> acc + n
      {:y, n, _}, acc -> acc + (100 * n)
    end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R\R/)
    |> Enum.map(fn pattern ->
      pattern
      |> String.split(~r/\R/)
      |> Enum.with_index()
      |> Enum.reduce(MapSet.new(), fn {line, y}, acc ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {c, x}, line_acc ->
          MapSet.put(line_acc, {x, y, c})
        end)
      end)
    end)
  end

  defp find_reflection(coords) do
    (x_reflection(coords) ++ y_reflection(coords))
    |> Enum.sort_by(fn {_, _, set} -> MapSet.size(set) end)
  end

  defp x_reflection(coords) do
    {{x_min, _, _}, {x_max, _, _}} = Enum.min_max_by(coords, &elem(&1, 0))
    Enum.map(x_min..(x_max - 1), &{:x, &1 - x_min + 1, x_reflection(coords, &1, x_min, x_max)})
    |> Enum.filter(fn {_, _, set} ->
      size = MapSet.size(set)
      size == 0 or size == 1
    end)
  end

  defp x_reflection(coords, x_i, x_min, x_max) when (x_i - x_min + 1) * 2 <= (x_max - x_min) + 1 do
    coords
    |> Enum.filter(fn {x, _, _} -> x <= x_i end)
    |> Enum.map(fn {x, y, c} -> {x_i + (x_i - x) + 1, y, c} end)
    |> MapSet.new()
    |> MapSet.difference(coords)
  end

  defp x_reflection(coords, x_i, _x_min, _x_max) do
    coords
    |> Enum.filter(fn {x, _, _} -> x > x_i end)
    |> Enum.map(fn {x, y, c} -> {x_i - (x - x_i) + 1, y, c} end)
    |> MapSet.new()
    |> MapSet.difference(coords)
  end

  defp y_reflection(coords) do
    {{_, y_min, _}, {_, y_max, _}} = Enum.min_max_by(coords, &elem(&1, 1))
    Enum.map(y_min..(y_max - 1), &{:y, &1 - y_min + 1, y_reflection(coords, &1, y_min, y_max)})
    |> Enum.filter(fn {_, _, set} ->
      size = MapSet.size(set)
      size == 0 or size == 1
    end)
  end

  defp y_reflection(coords, y_i, y_min, y_max) when (y_i - y_min + 1) * 2 <= (y_max - y_min) + 1 do
    coords
    |> Enum.filter(fn {_, y, _} -> y <= y_i end)
    |> Enum.map(fn {x, y, c} -> {x, y_i + (y_i - y) + 1, c} end)
    |> MapSet.new()
    |> MapSet.difference(coords)
  end

  defp y_reflection(coords, y_i, _y_min, _y_max) do
    coords
    |> Enum.filter(fn {_, y, _} -> y > y_i end)
    |> Enum.map(fn {x, y, c} -> {x, y_i - (y - y_i) + 1, c} end)
    |> MapSet.new()
    |> MapSet.difference(coords)
  end
end

input = File.read!("input/13.txt")

input |> Thirteen.part_one() |> IO.inspect(label: "part 1")
input |> Thirteen.part_two() |> IO.inspect(label: "part 2")
