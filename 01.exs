defmodule One do
  def part_one(input) do
    input
    |> parse()
    |> Enum.map(fn line ->
      a =
        line
        |> String.graphemes()
        |> Enum.find(&(&1 =~ ~r/\d/))
      b =
        line
        |> String.graphemes()
        |> Enum.reverse()
        |> Enum.find(&(&1 =~ ~r/\d/))
      String.to_integer(a <> b)
    end)
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.map(fn line ->
      a = line |> first_digit() |> parse_digit()
      b = line |> last_digit() |> parse_digit()
      String.to_integer(a <> b)
    end)
    |> Enum.sum()
  end

  defp first_digit(str = <<_, rest::binary>>) do
    digits = Enum.map(1..9, &Integer.to_string/1) ++ ~w[one two three four five six seven eight nine]
    case Enum.find(digits, fn digit -> String.starts_with?(str, digit) end) do
      nil -> first_digit(rest)
      first -> first
    end
  end

  defp last_digit(str, last \\ nil)
  defp last_digit("", last), do: last
  defp last_digit(str = <<_, rest::binary>>, last) do
    digits = Enum.map(1..9, &Integer.to_string/1) ++ ~w[one two three four five six seven eight nine]
    case Enum.find(digits, fn digit -> String.starts_with?(str, digit) end) do
      nil -> last_digit(rest, last)
      match -> last_digit(rest, match)
    end
  end

  defp parse_digit(str) do
    if str =~ ~r/\d/ do
      str
    else
      Enum.find_index(~w[がんばって one two three four five six seven eight nine], &(&1 == str))
      |> Integer.to_string()
    end
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
  end
end

input = File.read!("input/01.txt")

input |> One.part_one() |> IO.inspect(label: "part 1")
input |> One.part_two() |> IO.inspect(label: "part 2")
