defmodule SmallestFreeNumber do
  @moduledoc """
  An elixir implementation for the following problem.

  Problem: Computing the smallest natural number not in a given finite set X of natural numbers (zero included).
  """

  @doc """
  Solution based on divide and conquer

  ## Examples

      iex> SmallestFreeNumber.min_free([3, 8, 2, 7, 1, 0])
      4
      iex> SmallestFreeNumber.min_free([])
      0
      iex> SmallestFreeNumber.min_free([0, 1, 2])
      3
  """
  @spec min_free([non_neg_integer]) :: non_neg_integer
  def min_free(xs) do
    min_from(0, xs)
  end

  def min_from(a, xs) when length(xs) == 0, do: a

  def min_from(a, xs) do
    ## Select b
    b = a + 1 + (xs |> length |> div(2))

    ## Partition xs by b to (us, vs);
    ## Recur based on whether length(us) == b - a, which means no free number in us.
    case Enum.split_with(xs, fn x -> x < b end) do
      {us, vs} when length(us) == b - a ->
        min_from(b, vs)

      {us, _} ->
        min_from(a, us)
    end
  end
end
