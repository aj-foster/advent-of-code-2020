defmodule Day17Helper do
  @moduledoc """
  This modules provides several macros for use in today's solution. In this case, we're using
  macros to pre-calculate a list of values so we don't have to generate it over and over again
  each time we run a function.
  """

  @doc """
  Inserts a list of all coordinates that are off-by-one from the origin in a 3D space.
  """
  @spec off_by_ones_3d :: [{number, number, number}]
  defmacro off_by_ones_3d do
    list =
      for x <- [-1, 0, 1],
          y <- [-1, 0, 1],
          z <- [-1, 0, 1],
          {x, y, z} != {0, 0, 0} do
        {x, y, z}
      end
      |> Macro.escape()

    quote do
      unquote(list)
    end
  end

  @doc """
  Inserts a list of all coordinates that are off-by-one from the origin in a 4D space.
  """
  @spec off_by_ones_4d :: [{number, number, number, number}]
  defmacro off_by_ones_4d do
    list =
      for x <- [-1, 0, 1],
          y <- [-1, 0, 1],
          z <- [-1, 0, 1],
          w <- [-1, 0, 1],
          {x, y, z, w} != {0, 0, 0, 0} do
        {x, y, z, w}
      end
      |> Macro.escape()

    quote do
      unquote(list)
    end
  end
end
