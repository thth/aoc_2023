defmodule TwentyOne do
  @chunk_size 1000

  def part_one(input) do
    {plots, start} = parse(input)
    {plots, start}
    |> walk(64)
    |> Enum.count(fn {x, y} ->
      {xs, ys} = start
      if rem(xs + ys, 2) == 0, do: rem(x + y, 2) == 0, else: rem(x + y, 2) != 0
    end)
  end

  # i dont want to math
  # (i think this bruteforce solution could run on the order of magnitude of tens of days)
  def part_two(input) do
    {plots, start} = parse(input)
    {plots, start}
    |> count_walk(26_501_365)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.with_index()
    |> Enum.reduce({MapSet.new(), nil}, fn {line, y}, acc ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn
        {"S", x}, {plots, _} -> {MapSet.put(plots, {x, y}), {x, y}}
        {".", x}, {plots, s} -> {MapSet.put(plots, {x, y}), s}
        {"#", _}, acc2 -> acc2
      end)
    end)
    |> then(fn {plots, start} ->
      {{min_x, _}, {max_x, _}} = Enum.min_max_by(plots, &elem(&1, 0))
      {{_, min_y}, {_, max_y}} = Enum.min_max_by(plots, &elem(&1, 1))
      {{plots, max_x - min_x + 1, max_y - min_y + 1}, start}
    end)
  end

  defp walk({plots, start}, steps), do: walk([start], [], MapSet.new(), plots, steps)
  defp walk(_, _, seen, _, 0), do: seen
  defp walk([], nexts, seen, plots, steps), do: walk(nexts, [], seen, plots, steps - 1)
  defp walk([pos | rest], nexts, seen, plots, steps) do
    new_nexts =
      adj(pos, plots)
      |> Enum.reject(&MapSet.member?(seen, &1))
    new_seen = MapSet.new(new_nexts) |> MapSet.union(seen)
    walk(rest, new_nexts ++ nexts, new_seen, plots, steps)
  end

  defp adj({x, y}, {plots, _, _}) do
    [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
    |> Enum.filter(&MapSet.member?(plots, &1))
  end

  defp count_walk({plots, {start_x, start_y}}, steps) do
    seen = %{{div(start_x, @chunk_size), div(start_y, @chunk_size)} =>
      %{tiles: MapSet.new([{start_x, start_y}]), used?: true}}
    parity? = if rem(steps, 2) == 0, do: rem(start_x + start_y, 2) == 0, else: rem(start_x + start_y, 2) != 0
    count_walk([{start_x, start_y}], [], seen, 0, plots, parity?, steps)
  end
  defp count_walk([], _, _, count, _, _, 0), do: count
  defp count_walk([], nexts, seen, count, plots, parity?, steps) do
    count_walk(nexts, [], seen_clean(seen), count, plots, !parity?, steps - 1)
  end
  defp count_walk([pos | rest], nexts, seen, count, plots, parity?, steps) do
    {int_seen, new_nexts} =
      infinite_adj(pos, plots)
      |> Enum.reduce({seen, []}, fn adj, {seen_acc, nexts_acc} ->
        case seen_has?(seen_acc, adj) do
          {new_seen, false} -> {new_seen, [adj | nexts_acc]}
          {new_seen, true} -> {new_seen, nexts_acc}
        end
      end)
    new_seen =
      new_nexts
      |> Enum.reduce(int_seen, fn next, acc ->
        seen_add(acc, next)
      end)
    new_count = if parity?, do: count + 1, else: count
    count_walk(rest, new_nexts ++ nexts, new_seen, new_count, plots, parity?, steps)
  end

  defp infinite_adj({x, y}, {plots, x_len, y_len}) do
    [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
    |> Enum.filter(fn {i, j} ->
      MapSet.member?(plots, {fix(i, x_len), fix(j, y_len)})
    end)
  end

  defp fix(n, m) do
    case rem(n, m) do
      r when r < 0 -> r + m
      r -> r
    end
  end

  defp seen_clean(seen) do
    seen
    |> Stream.reject(fn {_, chunk} -> chunk.used? == false end)
    |> Stream.map(fn {k, chunk} -> {k, %{chunk | used?: false}} end)
    |> Enum.into(%{})
  end

  defp seen_has?(seen, {x, y}) do
    {cx, cy} = {div(x, @chunk_size), div(y, @chunk_size)}
    new_seen =
      (for i <- (cx-1)..(cx+1), j <- (cy-1)..(cy+1), do: {i, j})
      |> Enum.reduce(seen, fn chunk_pos, acc ->
        Map.update(acc, chunk_pos, %{used?: true, tiles: MapSet.new()}, fn chunk -> %{chunk | used?: true} end)
      end)
    has? = MapSet.member?(new_seen[{cx, cy}].tiles, {x, y})
    {new_seen, has?}
  end

  defp seen_add(seen, {x, y}) do
    chunk_pos = {div(x, @chunk_size), div(y, @chunk_size)}
    Map.update!(seen, chunk_pos, fn chunk ->
      %{chunk |
        tiles: MapSet.put(chunk.tiles, {x, y}),
        used?: true
      }
    end)
  end

  def draw(map) do
    set = MapSet.new(map)
    {{min_x, _}, {max_x, _}} = Enum.min_max_by(map, &elem(&1, 0))
    {{_, min_y}, {_, max_y}} = Enum.min_max_by(map, &elem(&1, 1))
    for y <- min_y..max_y,
        x <- min_x..max_x do
      IO.write(if MapSet.member?(set, {x, y}), do: ".", else: "#")
      if x == max_x, do: IO.write("\n")
    end
    map
  end
end

input = File.read!("input/21.txt")

input |> TwentyOne.part_one() |> IO.inspect(label: "part 1")
input |> TwentyOne.part_two() |> IO.inspect(label: "part 2")
