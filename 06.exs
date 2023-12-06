defmodule Six do
  def part_one(input) do
    input
    |> parse_one()
    |> Enum.map(fn {total_t, record} ->
      Enum.count(0..total_t, fn charge_t ->
        distance(charge_t, total_t) > record
      end)
    end)
    |> Enum.product()
  end

  def part_two(input) do
    input
    |> parse_two()
    |> then(fn {t, r} ->
      a = (t + :math.sqrt((t * t) - (4 * r))) / 2
      b = (t - :math.sqrt((t * t) - (4 * r))) / 2
      abs(trunc(:math.ceil(b) - :math.ceil(a)))
    end)
  end

  defp parse_one(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      line
      |> String.split(["Time:", "Distance:", " "], trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.zip()
  end

  defp distance(charge_t, total_t) do
    (total_t - charge_t) * charge_t
  end

  defp parse_two(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      line
      |> String.graphemes()
      |> Enum.filter(&(&1 =~ ~r/\d/))
      |> Enum.join()
      |> String.to_integer()
    end)
    |> List.to_tuple()
  end
end

input = File.read!("input/06.txt")

input |> Six.part_one() |> IO.inspect(label: "part 1")
input |> Six.part_two() |> IO.inspect(label: "part 2")
