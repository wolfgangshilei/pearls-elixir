defmodule SaddlebackSearch do
  @moduledoc """
  Problem:
  To design a function that takes two arguments: a function f from pairs of natural numbers to natural numbers,
  and a natural number z. The value invert f z is a list of all pairs (x,y) satisfying f(x,y) = z.
  It is assumed that f is strictly increasing in each argument, but nothing else.

  This module provides two implementations: the classic saddleback search and the divide and conquer approach.
  To see the practical comparisons of the two algorithms, run "mix test --exclude benchmark test/3/" from the
  pearls project root.
  """

  @doc """
  Implementation of the binary search algorithm.
  Given a function f, a target value z, and a pair of natural number {a, b},
  bsearch finds a natural number m (a <= m < b) such that f(m) <= z < f(m+1)

  Example:

    iex> SaddlebackSearch.bsearch(&(:math.pow &1, 2), {0, 5}, 7)
    2

    iex> SaddlebackSearch.bsearch(&(:math.pow &1, 2), {0, 5}, 25)
    4

    iex> SaddlebackSearch.bsearch(&(:math.pow &1, 2), {0, 5}, 16)
    4
  """
  def bsearch(_, {a, b}, _) when (a+1 == b), do: a  ## m must strictly smaller than b
  def bsearch(f, {a, b}, z) do
    m = (a+b) |> div(2)
    case f.(m) do
      n when n == z ->
        m
      n when n < z ->
        bsearch(f, {m, b}, z)
      n when n > z ->
        bsearch(f, {a, m}, z)
    end
  end

  @doc """
  An implementation of the classic saddleback search algorithm.
  This implementation requires (2log z + m + n) evaluations of f in the worst case (a trace of zigzag line)
  and (2logz + m min n) in the best case (a strait line along one axis).

  Example:
    iex> f = &(&1+&2)
    iex> z = 15
    iex> a = SaddlebackSearch.classic_saddleback(f, z)
    [{15, 0}, {14, 1}, {13, 2}, {12, 3}, {11, 4}, {10, 5}, {9, 6}, {8, 7}, {7, 8}, {6, 9}, {5, 10}, {4, 11}, {3, 12}, {2, 13}, {1, 14}, {0, 15}]
    iex> length(a) == 16
    true
    iex> Enum.all?(a, fn {x, y} -> f.(x, y) == z end)
    true

    iex> f = &(:math.pow (&1+&2), 2)
    iex> SaddlebackSearch.classic_saddleback(f, 3)
    []
  """
  def classic_saddleback(f, z) do
    ##
    m = bsearch(&(f.(0, &1)), {0, z+1}, z)
    n = bsearch(&(f.(&1, 0)), {0, z+1}, z)

    find({0 ,m}, f, z, n, [])
  end

  @doc false
  defp find({x, y}, _, _, n, acc) when (y < 0) or (x > n), do: acc
  defp find({x, y}, f, z, n, acc) do
    case f.(x, y) |> round do
      ^z ->
        find({x+1, y-1}, f, z, n, [{x, y} | acc])
      v when v > z ->
        find({x, y-1}, f, z, n, acc)
      _ ->
        find({x+1, y}, f, z, n, acc)
    end
  end

  @doc """
  A divide and conquer implementation of this problem.
  Theoretically this approch is an asymptotically optimal solution to this problem.
  And it is reportedly run faster pratically than the classic saddleback search.

  Example:
    iex> f = &(&1+&2)
    iex> z = 15
    iex> a = SaddlebackSearch.divide_and_conquer(f, z)
    [{7, 8}, {3, 12}, {1, 14}, {0, 15}, {2, 13}, {5, 10}, {4, 11}, {6, 9}, {11, 4}, {9, 6}, {8, 7}, {10, 5}, {13, 2}, {12, 3}, {14, 1}, {15, 0}]
    iex> length(a) == 16
    true
    iex> Enum.all?(a, fn {x, y} -> f.(x, y) == z end)
    true

    iex> f = &(:math.pow (&1+&2), 2)
    iex> SaddlebackSearch.divide_and_conquer(f, 3)
    []
  """
  def divide_and_conquer(f, z) do
    find_daq f, {0, z}, {z, 0}, z
  end


  # find_daq takes four arguments:
  # f is the input function and z is target value to be found;
  # {u, v} represents the top-left corner, while {r, s} the bottom-right of the rectangle
  # to be searched.
  defp find_daq(_, {u, v}, {r, s}, _) when (v < s) or (r < u), do: []
  defp find_daq(f, {u, v}, {r, s}, z) when (r - u) <= (v - s) do
    p = div (r + u), 2
    q = bsearch &(f.(p, &1)), {s, v+1}, z
    case f.(p, q) |> round do
      ## by definition of bsearch f(p, q) <= z
      ^z ->
        ## exclude the column and row where {p, q} resides and recurs on the left-top and
        ## bottom-right rectangles
        [{p, q} | find_daq(f, {u, v}, {p - 1, q + 1}, z)] ++ find_daq(f, {p + 1, q - 1}, {r, s}, z)
      _ ->
        ## n < z
        ## exclude the column p and recurs on the left-top and
        ## bottom-right rectangles
        find_daq(f, {u, v}, {p - 1, q + 1}, z) ++ find_daq(f, {p + 1, q}, {r, s}, z)
    end
  end
  defp find_daq(f, {u, v}, {r, s}, z) do
    ## the dual case of the above one
    q = div (v + s), 2
    p = bsearch &(f.(&1, q)), {u, r+1}, z
    case f.(p, q) |> round do
      ^z ->
        [{p, q} | find_daq(f, {u, v}, {p - 1, q + 1}, z)] ++ find_daq(f, {p + 1, q - 1}, {r, s}, z)
      _ ->
        find_daq(f, {u, v}, {p, q + 1}, z) ++ find_daq(f, {p + 1, q - 1}, {r, s}, z)
    end
  end
end
