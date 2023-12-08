defmodule Eight do
  def part_one(input) do
    {ins, map} = parse(input)
    ins
    |> Stream.cycle()
    |> Enum.reduce_while({"AAA", 0}, fn dir, {location, i} ->
      case map[{location, dir}] do
        "ZZZ" -> {:halt, i + 1}
        dest -> {:cont, {dest, i + 1}}
      end
    end)
  end

  def part_two(input) do
    {ins, map} = parse(input)
    starts =
      map
      |> Map.keys()
      |> Enum.map(&elem(&1, 0))
      |> Enum.uniq()
      |> Enum.filter(&match?(<<_::binary-size(2), "A">>, &1))
      |> Enum.map(fn location -> {:unlooped, location, MapSet.new([location])} end)

    ins
    |> Enum.with_index()
    |> Stream.cycle()
    |> Enum.reduce_while({starts, 0}, fn {dir, dir_i}, {locations, i} ->
      new_locations =
        locations
        |> Enum.map(fn
          {:unlooped, location, been} ->
            next = map[{location, dir}]
            if MapSet.member?(been, {next, dir_i}) do
              {:looping, next, {next, dir_i}, %{}, i, 0}
            else
              {:unlooped, next, MapSet.put(been, {next, dir_i})}
            end
          {:looping, location, origin, destinations, loop_start, steps} ->
            next = map[{location, dir}]
            # |> IO.inspect()
            if {next, dir_i} == origin do
              {:looped, destinations, loop_start, steps + 1}
            else
              new_destinations =
                if match?(<<_::binary-size(2), "Z">>, next) do
                  Map.put_new(destinations, next, steps + 2)
                else
                  destinations
                end
              {:looping, next, origin, new_destinations, loop_start, steps + 1}
            end
          looped ->
            looped
        end)
      if Enum.all?(new_locations, &(elem(&1, 0) == :looped)) do
        {:halt, new_locations}
      else
        {:cont, {new_locations, i + 1}}
      end
    end)
    |> Enum.map(&elem(&1, 3))
    |> Enum.reduce(&lcm/2)
  end

  defp parse(text) do
    [ins, nodes] =
      text
      |> String.trim()
      |> String.split(~r/\R\R/)
    map =
      nodes
      |> String.split(~r/\R/)
      |> Enum.map(fn <<o::binary-size(3), " = (", l::binary-size(3), ", ", r::binary-size(3), ")">> ->
        [{{o, "L"}, l}, {{o, "R"}, r}]
      end)
      |> List.flatten()
      |> Enum.into(%{})

    {String.graphemes(ins), map}
  end

  # from rosettacode
  def gcd(a,0), do: abs(a)
  def gcd(a,b), do: gcd(b, rem(a,b))
  def lcm(a,b), do: div(abs(a*b), gcd(a,b))
end

input = File.read!("input/08.txt")

input |> Eight.part_one() |> IO.inspect(label: "part 1")
input |> Eight.part_two() |> IO.inspect(label: "part 2")
