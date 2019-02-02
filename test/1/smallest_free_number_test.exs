defmodule SmallestFreeNumberTest do
  use ExUnit.Case
  @moduletag timeout: 300_000

  doctest SmallestFreeNumber

  @test_configuration [
    time: 10,
    warmup: 2,
    unit_scaling: :best,
    formatters: [
      Benchee.Formatters.HTML,
      Benchee.Formatters.Console
    ],
    formatter_options: [html: [file: "samples_output/1/sfn.html"]]
  ]

  @tag :benchmark
  test "Benchmarking SmallestFreeNumber.min_free/1" do
    input_lengths = [1_000, 5_000, 10_000, 50_000, 100_000, 500_000, 1_000_000]

    jobs =
      input_lengths
      |> Enum.map(fn len -> {title(len), list_with_free_numbers(len)} end)
      |> Enum.map(&make_job/1)

    Benchee.run(jobs, @test_configuration)
  end

  defp title(len), do: "List length: #{len}"

  defp make_job({title, list}) do
    {title, fn -> SmallestFreeNumber.min_free(list) end}
  end

  defp list_with_free_numbers(len) do
    Enum.take_random(0..(len - 1), len - div(len, 10))
  end
end
