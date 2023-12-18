defmodule Eighteen do
  def part_one(input) do
    input
    |> parse()
    |> run()
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.map(&convert/1)
    |> run()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      [dir, steps, colour] = String.split(line, " ")
      {dir, String.to_integer(steps), String.slice(colour, 1..-2)}
    end)
  end

  defp run(instructions), do: run(instructions, 0, 0)
  defp run([], _pos, area), do: trunc(area) + 1
  defp run([{"R", d, _} | rest], x, area), do: run(rest, x + d, area + (d / 2))
  defp run([{"L", d, _} | rest], x, area), do: run(rest, x - d, area + (d / 2))
  defp run([{"U", d, _} | rest], x, area), do: run(rest, x, area - (x * d) + (d / 2))
  defp run([{"D", d, _} | rest], x, area), do: run(rest, x, area + (x * d) + (d / 2))

  defp convert({_, _, <<"#", s::binary-size(5), d>>}) do
    dir =
      case d do
        ?0 -> "R"
        ?1 -> "D"
        ?2 -> "L"
        ?3 -> "U"
      end
    steps = String.to_integer(s, 16)
    {dir, steps, nil}
  end
end

input = File.read!("input/18.txt")

input |> Eighteen.part_one() |> IO.inspect(label: "part 1")
input |> Eighteen.part_two() |> IO.inspect(label: "part 2")
