defmodule Nineteen do
  def part_one(input) do
    {workflows, parts} = parse(input)
    parts
    |> Enum.filter(&accepted?(&1, workflows))
    |> Enum.map(&Map.values/1)
    |> List.flatten()
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> elem(0)
    |> solve()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R\R/)
    |> then(fn [a, b] ->
      workflows =
        a
        |> String.trim()
        |> String.split(~r/\R/)
        |> Enum.map(fn line ->
          line
          |> String.split(~w[{ , }], trim: true)
          |> then(fn [name | rest] ->
            conditions =
              rest
              |> Enum.slice(0..-2)
              |> Enum.map(fn <<c::binary-size(1), o::binary-size(1), r::binary>> ->
                [n, d] = String.split(r, ":")
                {c, o, String.to_integer(n), d}
              end)
              |> then(fn list -> list ++ [List.last(rest)] end)
            {name, conditions}
          end)
        end)
        |> Enum.into(%{})
      parts =
        b
        |> String.split(~r/\R/)
        |> Enum.map(fn line ->
          line
          |> String.split(~r/\D/, trim: true)
          |> Enum.map(&String.to_integer/1)
          |> then(fn [x, m, a, s] -> %{"x" => x, "m" => m, "a" => a, "s" => s} end)
        end)
      {workflows, parts}
    end)
  end

  defp accepted?(part, workflows),do: accepted?(part, workflows["in"], Map.merge(%{"A" => ["A"], "R" => ["R"]}, workflows))
  defp accepted?(_, ["A" | _], _), do: true
  defp accepted?(_, ["R" | _], _), do: false
  defp accepted?(part, [d], workflows), do: accepted?(part, workflows[d], workflows)
  defp accepted?(part, [{c, ">", n, d} | rest], workflows) do
    if part[c] > n, do: accepted?(part, workflows[d], workflows), else: accepted?(part, rest, workflows)
  end
  defp accepted?(part, [{c, "<", n, d} | rest], workflows) do
    if part[c] < n, do: accepted?(part, workflows[d], workflows), else: accepted?(part, rest, workflows)
  end

  defp solve(workflows), do: solve(
    [{(for c <- ~w[x m a s], into: %{}, do: {c, 1..4000}), workflows["in"]}],
    0,
    Map.merge(%{"A" => ["A"], "R" => ["R"]}, workflows))
  defp solve([], total, _), do: total
  defp solve([{ranges, ["A"]} | nexts], total, workflows), do: solve(nexts, total + count(ranges), workflows)
  defp solve([{_, ["R"]} | nexts], total, workflows), do: solve(nexts, total, workflows)
  defp solve([{ranges, [d]} | nexts], total, workflows), do: solve([{ranges, workflows[d]} | nexts], total, workflows)
  defp solve([{ranges, [{c, ">", n, d} | rest]} | nexts], total, workflows) do
    cond do
      Enum.max(ranges[c]) <= n -> solve([{ranges, rest} | nexts], total, workflows)
      Enum.min(ranges[c]) > n -> solve([{ranges, workflows[d]} | nexts], total, workflows)
      true ->
        solve([
          {%{ranges | c => (n + 1)..Enum.max(ranges[c])}, workflows[d]},
          {%{ranges | c => Enum.min(ranges[c])..n}, rest}
        | nexts], total, workflows)
    end
  end
  defp solve([{ranges, [{c, "<", n, d} | rest]} | nexts], total, workflows) do
    cond do
      Enum.min(ranges[c]) >= n -> solve([{ranges, rest} | nexts], total, workflows)
      Enum.max(ranges[c]) < n -> solve([{ranges, workflows[d]} | nexts], total, workflows)
      true ->
        solve([
          {%{ranges | c => Enum.min(ranges[c])..(n - 1)}, workflows[d]},
          {%{ranges | c => n..Enum.max(ranges[c])}, rest}
        | nexts], total, workflows)
    end
  end

  defp count(ranges) do
    ranges
    |> Map.values()
    |> Enum.map(&Range.size/1)
    |> Enum.product()
  end
end

input = File.read!("input/19.txt")

input |> Nineteen.part_one() |> IO.inspect(label: "part 1")
input |> Nineteen.part_two() |> IO.inspect(label: "part 2")
