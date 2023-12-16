defmodule Sixteen do
  def part_one(input) do
    input
    |> parse()
    |> count_energized({{0, 0}, :e})
  end

  def part_two(input) do
    map = parse(input)
    {{max_x, _}, _} = Enum.max_by(map, fn {{x, _}, _} -> x end)
    {{_, max_y}, _} = Enum.max_by(map, fn {{_, y}, _} -> y end)
    starts =
      (for x <- 0..max_x, do: {{x, 0}, :s})
      ++ (for x <- 0..max_x, do: {{x, max_y}, :n})
      ++ (for y <- 0..max_y, do: {{0, y}, :e})
      ++ (for y <- 0..max_y, do: {{max_x, y}, :w})
    best = Enum.max_by(starts, &count_energized(map, &1))
    count_energized(map, best)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, y}, acc ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, x}, map -> Map.put(map, {x, y}, c) end)
    end)
  end

  defp count_energized(map, start) do
    map
    |> run(start)
    |> Enum.map(fn {coords, _dir} -> coords end)
    |> Enum.uniq()
    |> Enum.count()
  end

  defp run(map, start) do
    {{max_x, _}, _} = Enum.max_by(map, fn {{x, _}, _} -> x end)
    {{_, max_y}, _} = Enum.max_by(map, fn {{_, y}, _} -> y end)
    run([start], [], {map, max_x, max_y}, MapSet.new())
  end
  defp run([], [], _, been), do: been
  defp run([], next, map_info, been), do: run(next, [], map_info, been)
  defp run([beam | rest], next, map_info, been) do
    if MapSet.member?(been, beam) do
      run(rest, next, map_info, been)
    else
      run(rest, run_beam(beam, map_info) ++ next, map_info, MapSet.put(been, beam))
    end
  end

  defp run_beam({coords, dir}, {map, max_x, max_y}) do
    tile = map[coords]
    beams = run_beam(coords, dir, tile)
    Enum.reject(beams, fn {{x, y}, _} ->
      x > max_x
      or x < 0
      or y > max_y
      or y < 0
    end)
  end

  defp run_beam({x, y}, :n, "."), do: [{{x, y - 1}, :n}]
  defp run_beam({x, y}, :s, "."), do: [{{x, y + 1}, :s}]
  defp run_beam({x, y}, :e, "."), do: [{{x + 1, y}, :e}]
  defp run_beam({x, y}, :w, "."), do: [{{x - 1, y}, :w}]
  defp run_beam({x, y}, :n, "|"), do: [{{x, y - 1}, :n}]
  defp run_beam({x, y}, :s, "|"), do: [{{x, y + 1}, :s}]
  defp run_beam({x, y}, :e, "|"), do: [{{x, y - 1}, :n}, {{x, y + 1}, :s}]
  defp run_beam({x, y}, :w, "|"), do: [{{x, y - 1}, :n}, {{x, y + 1}, :s}]
  defp run_beam({x, y}, :n, "-"), do: [{{x + 1, y}, :e}, {{x - 1, y}, :w}]
  defp run_beam({x, y}, :s, "-"), do: [{{x + 1, y}, :e}, {{x - 1, y}, :w}]
  defp run_beam({x, y}, :e, "-"), do: [{{x + 1, y}, :e}]
  defp run_beam({x, y}, :w, "-"), do: [{{x - 1, y}, :w}]
  defp run_beam({x, y}, :n, "/"), do: [{{x + 1, y}, :e}]
  defp run_beam({x, y}, :s, "/"), do: [{{x - 1, y}, :w}]
  defp run_beam({x, y}, :e, "/"), do: [{{x, y - 1}, :n}]
  defp run_beam({x, y}, :w, "/"), do: [{{x, y + 1}, :s}]
  defp run_beam({x, y}, :n, "\\"), do: [{{x - 1, y}, :w}]
  defp run_beam({x, y}, :s, "\\"), do: [{{x + 1, y}, :e}]
  defp run_beam({x, y}, :e, "\\"), do: [{{x, y + 1}, :s}]
  defp run_beam({x, y}, :w, "\\"), do: [{{x, y - 1}, :n}]
end

input = File.read!("input/16.txt")

input |> Sixteen.part_one() |> IO.inspect(label: "part 1")
input |> Sixteen.part_two() |> IO.inspect(label: "part 2")
