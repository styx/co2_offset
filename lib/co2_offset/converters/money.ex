defmodule Co2Offset.Converters.Money do
  @moduledoc """
  Converter CO2 <-> money
  """

  @co2_per_dollar 100
  @minimum 5

  @spec convert_and_structure(%{optional(any) => any, co2: co2}) :: %{
          optional(any) => any,
          co2: co2,
          money: %{dollar: integer()}
        }
        when co2: float

  def convert_and_structure(acc) when is_map(acc) do
    acc[:co2]
    |> convert(:dollar_from_co2)
    |> structure(acc)
  end

  @spec convert(integer(), :co2_from_dollar | :dollar_from_co2) :: integer()
  def convert(dollar, :co2_from_dollar) when is_integer(dollar) do
    # credo:disable-for-next-line
    (dollar * @co2_per_dollar) |> round()
  end

  def convert(co2, :dollar_from_co2) when is_float(co2) do
    # credo:disable-for-next-line
    (co2 / @co2_per_dollar) |> round() |> max(@minimum)
  end

  defp structure(dollar, acc) do
    acc
    |> Map.put(:money, %{dollar: dollar})
  end
end
