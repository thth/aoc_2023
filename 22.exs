defmodule TwentyTwo do
  def part_one(input) do
    input
    |> parse()
    |> fall()
    |> then(fn {bricks, _} ->
      bricks = MapSet.new(bricks)
      Enum.count(bricks, fn brick ->
        group = MapSet.delete(bricks, brick)
        group
        |> fall()
        |> elem(0)
        |> MapSet.new()
        |> MapSet.equal?(group)
      end)
    end)
  end

  def part_two(input) do
    input
    |> parse()
    |> fall()
    |> then(fn {bricks, _} ->
      bricks = MapSet.new(bricks)
      Enum.map(bricks, fn brick ->
        MapSet.delete(bricks, brick)
        |> fall()
        |> elem(1)
      end)
      |> Enum.sum()
    end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      line
      |> String.split([",", "~"])
      |> Enum.map(&String.to_integer/1)
      |> then(fn [x1, y1, z1, x2, y2, z2] ->
        {min(x1, x2)..max(x1, x2), min(y1, y2)..max(y1, y2), min(z1, z2)..max(z1, z2)}
      end)
    end)
  end

  defp fall(bricks) do
    with_id =
      bricks
      |> Enum.sort_by(fn {_, _, z1.._} -> z1 end)
      |> Enum.map(fn brick -> {brick, brick} end)
    fall(with_id, [], MapSet.new(), false, MapSet.new())
  end
  defp fall([], fallen, _, false, ever_fallen), do: {Enum.map(fallen, &elem(&1, 0)), MapSet.size(ever_fallen)}
  defp fall([], fallen, _, true, ever_fallen), do: fall(Enum.reverse(fallen), [], MapSet.new(), false, ever_fallen)
  defp fall([{{_, _, 1.._} = brick, id} | rest], fallen, under_coords, any_fall?, ever_fallen) do
    fall(rest, [{brick, id} | fallen], add_brick(under_coords, brick), any_fall?, ever_fallen)
  end
  defp fall([{{xr, yr, z1..z2} = brick, id} | rest], fallen, under_coords, any_fall?, ever_fallen) do
    if brick_under?(under_coords, brick) do
      fall(rest, [{brick, id} | fallen], add_brick(under_coords, brick), any_fall?, ever_fallen)
    else
      new_brick = {xr, yr, (z1 - 1)..(z2 - 1)}
      new_ever_fallen = MapSet.put(ever_fallen, id)
      fall(rest, [{new_brick, id} | fallen], add_brick(under_coords, new_brick), true, new_ever_fallen)
    end
  end

  defp add_brick(mapset, {xr, yr, zr}) do
    (for x <- xr, y <- yr, z <- zr, do: {x, y, z})
    |> Enum.reduce(mapset, fn pos, acc ->
      MapSet.put(acc, pos)
    end)
  end

  defp brick_under?(coords, {xr, yr, z.._}) do
    (for x <- xr, y <- yr, do: {x, y, z - 1})
    |> Enum.any?(fn pos -> MapSet.member?(coords, pos) end)
  end
end

input = File.read!("input/22.txt")

input |> TwentyTwo.part_one() |> IO.inspect(label: "part 1")
input |> TwentyTwo.part_two() |> IO.inspect(label: "part 2")
