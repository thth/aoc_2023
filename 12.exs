defmodule Twelve do
  def part_one(input) do
    input
    |> parse()
    |> Enum.map(&count/1)
    |> Enum.sum()
  end

  # guaranteed to run before heat death of the universe or your money back
  def part_two(input) do
    input
    |> parse()
    |> Enum.map(fn {pattern, groups} ->
      new_pattern =
        pattern
        |> List.duplicate(5)
        |> Enum.intersperse(["?"])
        |> List.flatten()
      new_groups =
        groups
        |> List.duplicate(5)
        |> List.flatten()
      {new_pattern, new_groups}
    end)
    |> Task.async_stream(fn spring ->
      count(spring)
      # |> IO.inspect()
    end, timeout: :infinity)
    |> Stream.map(&elem(&1, 1))
    |> Enum.sum()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      [pattern | groups] = String.split(line, [" ", ","])
      pattern_list =
        pattern
        |> String.graphemes()
        |> remove_multiple_dots()
      {pattern_list, Enum.map(groups, &String.to_integer/1)}
    end)
  end

  defp remove_multiple_dots(p), do: remove_multiple_dots(p, [])
  defp remove_multiple_dots([c], removed), do: Enum.reverse([c | removed])
  defp remove_multiple_dots([".", "." | rest], removed), do: remove_multiple_dots(["." | rest], removed)
  defp remove_multiple_dots([a, b | rest], removed), do: remove_multiple_dots([b | rest], [a | removed])

  defp count({pattern, groups}),
    do: count([["." | pattern]], groups, 0, length(groups) - 1, 0)

  defp count([pattern | rest] = patterns, groups, g_i, g_max, t) when g_i < g_max do
    g_size = Enum.at(groups, g_i)
    cond do
      g_size <= length(pattern) - 1 and matches?(g_size, pattern) ->
        slice = Enum.slice(pattern, (g_size + 1)..-1)
        count([slice | patterns], groups, g_i + 1, g_max, t)
      g_size <= length(pattern) - 1 and hd(pattern) == "#" and g_i > 0 ->
        [p2 | r] = rest
        count([tl(p2) | r], groups, g_i - 1, g_max, t)
      g_size <= length(pattern) - 1 and hd(pattern) != "#" ->
        count([tl(pattern) | rest], groups, g_i, g_max, t)
      g_i > 0 ->
        [p2 | r] = rest
        count([tl(p2) | r], groups, g_i - 1, g_max, t)
      true ->
        t
    end
  end

  defp count([p1, p2 | rest], groups, g_max, g_max, t) do
    g_size = Enum.at(groups, g_max)
    cond do
      g_size > length(p1) - 1 or hd(p1) == "#" ->
        count([tl(p2) | rest], groups, g_max - 1, g_max, t)
      end_matches?(g_size, p1) ->
        count([tl(p1), p2 | rest], groups, g_max, g_max, t + 1)
      true ->
        count([tl(p1), p2 | rest], groups, g_max, g_max, t)
    end
  end

  defp matches?(_, ["#" | _]), do: false
  defp matches?(g_size, [_ | p_r]) when g_size == length(p_r) do
    Enum.all?(p_r, &(&1 != "."))
  end

  defp matches?(g_size, [_ | p_r]) do
    Enum.at(p_r, g_size) != "#"
      and (p_r |> Enum.take(g_size) |> Enum.all?(&(&1 != ".")))
  end

  defp end_matches?(_, ["#" | _]), do: false
  defp end_matches?(g_size, [_ | p_r]) when g_size == length(p_r) do
    Enum.all?(p_r, &(&1 != "."))
  end

  defp end_matches?(g_size, [_ | p_r]) do
    Enum.at(p_r, g_size) != "#"
      and (p_r |> Enum.take(g_size) |> Enum.all?(&(&1 != ".")))
      and (Enum.slice(p_r, g_size..-1) |> Enum.all?(&(&1 != "#")))
  end
end

input = File.read!("input/12.txt")

input |> Twelve.part_one() |> IO.inspect(label: "part 1")
input |> Twelve.part_two() |> IO.inspect(label: "part 2")
