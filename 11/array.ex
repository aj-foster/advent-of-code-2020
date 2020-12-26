defmodule Array do
  @moduledoc """
  Provides friendly wrappers around the `:array` module from OTP. While `:array` functions
  generally accept the array as a final argument, this module follows the Elixir convention and
  accepts the array as the first argument.

  This module also provides an implementation for the `Enumerable` protocol for Erlang arrays.
  Although there are certainly better ways to implement this protocol, it gets the job done in a
  fairly efficient manner. This allows us to use `Enum` functions on the array, often with the
  benefit of O(1) operations.
  """

  defstruct array: :array.new(), fold_index: 0

  @type t :: %__MODULE__{array: :array.array()}
  @type t(type) :: %__MODULE__{array: :array.array(type)}

  @doc """
  Create an array from the given list, optionally using `default` as the default element for
  unfilled elements.
  """
  @spec from_list(list :: Enumerable.t()) :: t
  @spec from_list(list :: Enumerable.t(), default :: term) :: t
  def from_list(list), do: %__MODULE__{array: :array.from_list(list)}
  def from_list(list, default), do: %__MODULE__{array: :array.from_list(list, default)}

  @doc """
  Map the given function over each element of the array. The function receives two argument: the
  element and its index.
  """
  @spec map_with_index(array :: t, fun :: (term, non_neg_integer -> term)) :: t
  def map_with_index(%Array{array: array} = s, fun) do
    %{s | array: :array.map(fn index, val -> fun.(val, index) end, array)}
  end

  @doc """
  Create a new, empty array.
  """
  @spec new :: t
  def new, do: %__MODULE__{array: :array.new()}

  defimpl Enumerable do
    @doc """
    Provides and O(1) implementation of `count/1` for arrays.
    """
    @spec count(Array.t()) :: {:ok, non_neg_integer} | {:error, module}
    def count(%Array{array: array}), do: {:ok, :array.size(array)}

    @doc """
    Leverages `:array.foldl/3` and a boolean accumulator to check for membership.
    """
    @spec member?(Array.t(), term) :: {:ok, boolean} | {:error, module}
    def member?(%Array{array: array}, value) do
      :array.foldl(fn _index, val, acc -> acc or val == value end, false, array)
    end

    @doc """
    Implements tagged reduction for arrays.

    Uses the `:fold_index` field of the struct to check for reaching the end of the array.
    """
    @spec reduce(Array.t(), Enumerable.acc(), Enumerable.reducer()) :: Enumerable.result()
    def reduce(_array, {:halt, acc}, _fun), do: {:halted, acc}
    def reduce(array, {:suspend, acc}, fun), do: {:suspended, acc, &reduce(array, &1, fun)}

    def reduce(%Array{array: array, fold_index: index}, {:cont, acc}, fun) do
      if index < :array.size(array) do
        next = :array.get(index, array)
        reduce(%Array{array: array, fold_index: index + 1}, fun.(next, acc), fun)
      else
        {:done, acc}
      end
    end

    @doc """
    Provides O(1) size information and slicing with speed based on the size of the slice.
    """
    @spec slice(Array.t()) :: {:ok, non_neg_integer, Enumerable.slicing_fun()}
    def slice(%Array{array: array}) do
      fun = fn start, length ->
        start..(start + length - 1)
        |> Enum.map(fn index -> :array.get(index, array) end)
      end

      {:ok, :array.size(array), fun}
    end
  end
end
