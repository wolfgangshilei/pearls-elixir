defmodule SurpassingCount do
  @moduledoc """
  Problem: A small programming exercise of Martin Rem. While Rem’s solution uses binary search, our solution is another application of divide and conquer.

  By definition, a surpasser of an element of an array is a greater element to the right, so x[j] is a surpasser of x[i] if i < j and x[i] < x[j].
  """

  @typedoc """
  Table entry. Tuple with list element and its surpassing_number in current table.
  """
  @type table_entry :: {number, non_neg_integer}

  @typedoc """
  Table. A list of table entries.
  """
  @type table :: [table_entry]

  @doc """
  It computes the maximum surpassing count of a given list in O(nlogn) time, where n is the input list's length.

  ## Examples

      iex> SurpassingCount.msc([])
      0
      iex> SurpassingCount.msc([1])
      0
      iex> SurpassingCount.msc([3,1,2,4,5])
      3
      iex> SurpassingCount.msc('GENERATING')
      6

  """
  @spec msc([number]) :: non_neg_integer
  def msc([]), do: 0
  def msc(list), do: table(list) |> Keyword.values |> Enum.max

  @spec table([number]) :: table
  defp table([x]), do: [{x, 0}]
  defp table(list) do
    m = length list
    n = div m, 2

    # the length of ys is thus m - n
    {xs, ys} = Enum.split list, n

    # dividing and joining tables.
    join(m-n, table(xs), table(ys))
  end

  # join runs in linear time in respect of the input tables' size.
  # This is the vital part of the divide and conquer solution for this problem.
  # The key is to preserve an ascending order of the table entries based on the list element's value while building up from small tables. This property enables to traverse the two tables only once in order to calculate the surpassing count when performing further joining.
  @spec join(non_neg_integer, table, table) :: table
  defp join(0, txs, []), do: txs
  defp join(_, [], tys), do: tys
  defp join(lys, [{x, c} | txs_tail], [{y, _} | _] = tys) when x < y do
    [{x, c + lys}] ++ join(lys, txs_tail, tys)
  end
  defp join(lys, [{x, _} | _] = txs, [{y, d} | tys_tail]) when x >= y do
    [{y, d}] ++ join(lys-1, txs, tys_tail)
  end
end
