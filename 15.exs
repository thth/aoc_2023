defmodule Fifteen do
  def part_one(input) do
    input
    |> parse()
    |> Enum.map(&hash/1)
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> run()
    |> focusing_power()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_charlist/1)
  end

  defp hash(charlist), do: hash(charlist, 0)
  defp hash([], v), do: v
  defp hash([c | rest], v) do
    hash(rest, rem((v + c) * 17, 256))
  end

  defp run(steps), do: run(steps, (for n <- 0..255, into: %{}, do: {n, []}))
  defp run([], boxes), do: boxes
  defp run([ins | rest], boxes) do
    case List.last(ins) do
      ?- ->
        l = Enum.slice(ins, 0..-2)
        run(rest, Map.update!(boxes, hash(l), &Enum.reject(&1, fn {label, _f} -> label == l end)))
      f ->
        l = Enum.slice(ins, 0..-3)
        new_boxes =
          case Enum.find_index(boxes[hash(l)], fn {label, _f} -> label == l end) do
            nil -> Map.update!(boxes, hash(l), &(&1 ++ [{l, f - 48}]))
            i ->
              Map.update!(boxes, hash(l), fn box ->
                List.replace_at(box, i, {l, f - 48})
              end)
          end
        run(rest, new_boxes)
    end
  end

  defp focusing_power(boxes) do
    boxes
    |> Enum.reduce(0, fn {box_n, box}, acc ->
      box
      |> Enum.with_index(1)
      |> Enum.reduce(acc, fn {{_label, f}, i}, acc2 ->
        acc2 + ((box_n + 1) * i * f)
      end)
    end)
  end
end

input = File.read!("input/15.txt")

input |> Fifteen.part_one() |> IO.inspect(label: "part 1")
input |> Fifteen.part_two() |> IO.inspect(label: "part 2")
