defmodule Seven do
  def part_one(input) do
    input
    |> parse()
    |> Enum.sort_by(&elem(&1, 0), &type_sort/2)
    |> Enum.with_index(1)
    |> Enum.map(fn {{_, bet}, rank} -> bet * rank end)
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.sort_by(&elem(&1, 0), &joker_sort/2)
    |> Enum.with_index(1)
    |> Enum.map(fn {{_, bet}, rank} -> bet * rank end)
    |> Enum.sum()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      [hand, bet] = String.split(line, " ")
      {String.graphemes(hand), String.to_integer(bet)}
    end)
  end

  defp type_sort(h1, h2) do
    if type(h1) == type(h2) do
      order_sort(h1, h2)
    else
      type(h1) < type(h2)
    end
  end

  defp type(hand) do
    hand
    |> Enum.frequencies()
    |> Map.values()
    |> Enum.sort(:desc)
    |> frequency_rank()
  end

  defp frequency_rank([5]), do: 7
  defp frequency_rank([4, 1]), do: 6
  defp frequency_rank([3, 2]), do: 5
  defp frequency_rank([3, 1, 1]), do: 4
  defp frequency_rank([2, 2, 1]), do: 3
  defp frequency_rank([2, 1, 1, 1]), do: 2
  defp frequency_rank(_), do: 1

  defp order_sort([c | r1], [c | r2]), do: order_sort(r1, r2)
  defp order_sort([c1 | _], [c2 | _]),do: card_value(c1) < card_value(c2)

  defp card_value("A"), do: 14
  defp card_value("K"), do: 13
  defp card_value("Q"), do: 12
  defp card_value("J"), do: 11
  defp card_value("T"), do: 10
  defp card_value(card), do: String.to_integer(card)

  defp joker_sort(h1, h2) do
    if joker(h1) == joker(h2) do
      joker_order_sort(h1, h2)
    else
      joker(h1) < joker(h2)
    end
  end

  defp joker(hand) do
    hand
    |> Enum.reject(&(&1 == "J"))
    |> Enum.frequencies()
    |> Map.values()
    |> Enum.sort(:desc)
    |> then(fn
      [] -> [5]
      [n | rest] -> [n + Enum.count(hand, &(&1 == "J")) | rest]
    end)
    |> frequency_rank()
  end

  defp joker_order_sort(h1, h2) do
    replace_j = &(if &1 == "J", do: "1", else: &1)
    order_sort(Enum.map(h1, replace_j), Enum.map(h2, replace_j))
  end
end

input = File.read!("input/07.txt")

input |> Seven.part_one() |> IO.inspect(label: "part 1")
input |> Seven.part_two() |> IO.inspect(label: "part 2")
