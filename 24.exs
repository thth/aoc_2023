defmodule TwentyFour do
  @range 200_000_000_000_000..400_000_000_000_000

  def part_one(input) do
    input
    |> parse()
    |> then(fn paths -> for a <- paths, b <- paths, a != b, do: [a, b] |> Enum.sort() |> List.to_tuple() end)
    |> Enum.uniq()
    |> Enum.count(&intercept?(&1, @range))
  end

  def part_two(_input) do
    "lol math"
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      line
      |> String.split([",", "@"])
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.to_integer/1)
      |> then(fn [px, py, pz, vx, vy, vz] -> {{px, py, pz}, {vx, vy, vz}} end)
    end)
  end

  defp intercept?({{{apx, apy, _}, {avx, avy, _}}, {{bpx, bpy, _}, {bvx, bvy, _}}}, i..j) do
    a = avy / avx
    b = bvy / bvx
    c = apy - (apx * a)
    d = bpy - (bpx * b)
    if (a - b) == 0 do
      false
    else
      px = (d - c) / (a - b)
      py = (a * (d - c) / (a - b)) + c
      in_future?(px, apx, avx) and in_future?(py, apy, avy)
      and in_future?(px, bpx, bvx) and in_future?(py, bpy, bvy)
      and px >= i and px <= j and py >= i and py <= j
    end
  end

  defp in_future?(p, z, v), do: (if v > 0, do: p > z, else: p < z)
end

input = File.read!("input/24.txt")

input |> TwentyFour.part_one() |> IO.inspect(label: "part 1")
input |> TwentyFour.part_two() |> IO.inspect(label: "part 2")
