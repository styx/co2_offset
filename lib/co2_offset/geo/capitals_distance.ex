defmodule Co2Offset.Geo.CapitalsDistance do
  use Ecto.Schema

  @moduledoc """
  Capitals distance model. Generated from 3rd party data.
  Used for "Same distance as blocks"
  """

  schema "capitals_distances" do
    field :capital_a, :string
    field :capital_b, :string
    field :distance, :integer
  end
end