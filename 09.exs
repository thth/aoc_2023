defmodule Nine do
  def part_one(input) do
    input
    |> parse()
    |> Enum.map(fn line ->
      line
      |> Stream.iterate(&diffs/1)
      |> Enum.take_while(fn seq -> Enum.any?(seq, &(&1 != 0)) end)
      |> Enum.map(&List.last/1)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.map(fn line ->
      line
      |> Stream.iterate(&diffs/1)
      |> Enum.take_while(fn seq -> Enum.any?(seq, &(&1 != 0)) end)
      |> Enum.map(&List.first/1)
      |> Enum.with_index()
      |> Enum.reduce(0, fn
          {n, i}, acc when rem(i, 2) == 0 -> acc + n
          {n, _}, acc -> acc - n
      end)
    end)
    |> Enum.sum()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      line
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp diffs(line), do: diffs(line, [])
  defp diffs([_], list), do: Enum.reverse(list)
  defp diffs([a, b | rest], list), do: diffs([b | rest], [b - a | list])
end

input = File.read!("input/09.txt")

input |> Nine.part_one() |> IO.inspect(label: "part 1")
input |> Nine.part_two() |> IO.inspect(label: "part 2")
