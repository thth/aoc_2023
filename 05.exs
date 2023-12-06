defmodule Five do
  def part_one(input) do
    seeds = parse_seeds(input)
    maps = parse_maps(input)

    seeds
    |> Enum.map(&run(&1, maps))
    |> Enum.min()
  end

  def part_two(input) do
    seed_ranges = parse_seed_ranges(input)
    maps = parse_maps(input)

    Enum.map(seed_ranges, fn range ->
      Task.async(fn ->
        Enum.reduce(range, :infinity, fn seed, acc ->
          location = run(seed, maps)
          min(location, acc)
        end)
      end)
    end)
    |> Enum.map(&Task.await(&1, :infinity))
    |> Enum.min()
  end

  defp parse_seeds(text) do
    text
    |> String.trim()
    |> String.split(~r/\R\R/)
    |> List.first()
    |> String.split([" ", "seeds:"], trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp parse_maps(text) do
    text
    |> String.trim()
    |> String.split(~r/\R\R/)
    |> Enum.slice(1..-1)
    |> Enum.map(fn map ->
      map
      |> String.split(~r/\R/)
      |> Enum.slice(1..-1)
      |> Enum.map(fn line ->
        [dest, source, length] = String.split(line, " ") |> Enum.map(&String.to_integer/1)
        {source..(source+length-1), dest..(dest+length-1)}
      end)
      |> Enum.sort()
    end)
  end

  defp parse_seed_ranges(text) do
    text
    |> String.trim()
    |> String.split(~r/\R\R/)
    |> List.first()
    |> String.split([" ", "seeds:"], trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(2)
    |> Enum.map(fn [seed, range] -> seed..(seed + range) end)
  end

  defp run(n, []), do: n
  defp run(n, [map | rest]) do
    new_n =
      case Enum.find(map, fn {range, _} -> n in range end) do
        nil -> n
        {source.._, dest.._} -> n - source + dest
      end
    run(new_n, rest)
  end
end

input = File.read!("input/05.txt")

input |> Five.part_one() |> IO.inspect(label: "part 1")
input |> Five.part_two() |> IO.inspect(label: "part 2")
