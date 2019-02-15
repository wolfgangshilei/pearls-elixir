defmodule SaddlebackSearchTest do
  use ExUnit.Case
  @moduletag timeout: 600_000

  doctest SaddlebackSearch

  require Integer

  @doc false
  ## To bypass the limitation of :math.pow/2, which raises an error when the power is high.
  defp pow(_, 0), do: 1
  defp pow(x, n) when Integer.is_odd(n), do: x * pow(x, n - 1)
  defp pow(x, n) do
    result = pow(x, div(n, 2))
    result * result
  end

  defp f0(x, y), do: pow(2,y) * (2*x + 1) - 1
  defp f1(x, y), do: x*pow(2,x) + y*pow(2,y) + 2*x + y
  defp f2(x, y), do: 3*x + 27*y + pow(y,2)
  defp f3(x, y), do: pow(x,2) * pow(y,2) + x + y
  defp f4(x, y), do: x + pow(2,y) + y - 1


  ## Unit test
  test "Test SaddlebackSearch.classic_saddleback/2 and SaddlebackSearch.divide_and_conquer2 output the same answers for the same inputs." do

    assert SaddlebackSearch.classic_saddleback(&f0/2, 1000) ==
    (SaddlebackSearch.divide_and_conquer(&f0/2, 1000)
    |> Enum.sort_by(&(elem(&1, 1))))

    assert SaddlebackSearch.classic_saddleback(&f1/2, 1000) ==
    (SaddlebackSearch.divide_and_conquer(&f1/2, 1000)
    |> Enum.sort_by(&(elem(&1, 1))))

    assert SaddlebackSearch.classic_saddleback(&f2/2, 1000) ==
    (SaddlebackSearch.divide_and_conquer(&f2/2, 1000)
    |> Enum.sort_by(&(elem(&1, 1))))

    assert SaddlebackSearch.classic_saddleback(&f3/2, 1000) ==
    (SaddlebackSearch.divide_and_conquer(&f3/2, 1000)
    |> Enum.sort_by(&(elem(&1, 1))))

    assert SaddlebackSearch.classic_saddleback(&f4/2, 1000) ==
    (SaddlebackSearch.divide_and_conquer(&f4/2, 1000)
    |> Enum.sort_by(&(elem(&1, 1))))
  end

  ## Benchmark test
  @test_configuration [
    time: 10,
    warmup: 2,
    unit_scaling: :best,
    formatters: [
      Benchee.Formatters.HTML,
      Benchee.Formatters.Console
    ],
    formatter_options: [html: [file: "samples_output/3/saddleback.html"]]
  ]

  @tag :benchmark
  test "Benchmarking SaddlebackSearch.classic_saddleback/2 and SaddlebackSearch.divide_and_conquer/2" do

    inputs = %{
      "f: pow(2,y) * (2*x + 1) - 1; z: 5000" => {&f0/2, 5000},
      "f: x*pow(2,x) + y*pow(2,y) + 2*x + y; z: 5000" => {&f1/2, 5000},
      "f: 3*x + 27*y + pow(y,2); z: 5000" => {&f2/2, 5000},
      "f: pow(x,2) * pow(y,2) + x + y; z: 5000" => {&f3/2, 5000},
      "f: x + pow(2,y) + y - 1; z: 5000" => {&f4/2, 5000},
    }

    Benchee.run %{
      "classic saddleback" => fn {f, z} -> SaddlebackSearch.classic_saddleback(f, z) end,
      "divide and conquer" => fn {f, z} -> SaddlebackSearch.divide_and_conquer(f, z) end,
    }, Keyword.merge(@test_configuration, [inputs: inputs])
  end
end
