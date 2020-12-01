numbers =
  File.read!("input.txt")
  |> String.split("\n", trim: true)
  |> Stream.map(&Integer.parse/1)
  |> Stream.map(&elem(&1, 0))
  |> Enum.to_list()

for x <- numbers, y <- numbers do
  if x + y == 2020 do
    IO.puts("Part one: #{x * y}")
  end
end

for x <- numbers, y <- numbers, z <- numbers do
  if x + y + z == 2020 do
    IO.puts("Part two: #{x * y * z}")
  end
end
