defmodule Four do
  def part_one(input) do
    input
    |> parse()
    |> Enum.map(fn {_, wins, nums} -> matches(wins, nums) end)
    |> Enum.map(&score/1)
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> count_cards()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      [a, b, c] = String.split(line, ["Card", ":", "|"], trim: true)
      card = a |> String.trim() |> String.to_integer()
      wins = b |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1) |> MapSet.new()
      nums = c |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1) |> MapSet.new()
      {card, wins, nums}
    end)
  end

  defp matches(wins, nums), do: MapSet.intersection(wins, nums) |> MapSet.size()

  defp score(0), do: 0
  defp score(n), do: :math.pow(2, n - 1) |> trunc()

  defp count_cards(cards) do
    {last, _, _} = List.last(cards)
    count = for n <- 1..last, into: %{}, do: {n, 1}
    count_cards(cards, count)
  end

  defp count_cards([], count), do: count |> Map.values() |> Enum.sum()
  defp count_cards([{n, wins, nums} | rest], count) do
    case matches(wins, nums) do
      0 -> count_cards(rest, count)
      n_matches ->
        new_count =
          Enum.reduce((n + 1)..(n + n_matches), count, fn id, acc ->
            Map.update!(acc, id, fn v -> v + count[n] end)
          end)
        count_cards(rest, new_count)
    end
  end
end

input = File.read!("input/04.txt")

input |> Four.part_one() |> IO.inspect(label: "part 1")
input |> Four.part_two() |> IO.inspect(label: "part 2")
