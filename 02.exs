defmodule Two do
  def part_one(input) do
    input
    |> parse()
    |> Enum.reject(fn {_id, sets} ->
      Enum.any?(sets, fn set ->
        (set["red"] || 0) > 12 or (set["green"] || 0) > 13 or (set["blue"] || 0) > 14
      end)
    end)
    |> Enum.reduce(0, fn {id, _}, acc -> acc + id end)
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.map(fn {_id, sets} ->
      Enum.reduce(sets, [0, 0, 0], fn set, [max_r, max_g, max_b] ->
        [max(max_r, set["red"] || 0), max(max_g, set["green"] || 0), max(max_b, set["blue"] || 0)]
      end)
      |> Enum.product()
    end)
    |> Enum.sum()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      [id | rest] = String.split(line, ~r/Game |: |; /, trim: true)
      sets =
        Enum.map(rest, fn set ->
          String.split(set, ", ")
          |> Enum.map(fn combo ->
            [n, color] = String.split(combo, " ")
            {color, String.to_integer(n)}
          end)
          |> Enum.into(%{})
        end)
      {String.to_integer(id), sets}
    end)
  end
end

input = File.read!("input/02.txt")

input |> Two.part_one() |> IO.inspect(label: "part 1")
input |> Two.part_two() |> IO.inspect(label: "part 2")
