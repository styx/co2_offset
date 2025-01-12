defmodule Co2Offset.Calculators.CalculatorTest do
  use Co2Offset.DataCase, async: true

  alias Co2Offset.Calculators.Calculator

  test "valid factory" do
    assert(%Co2Offset.Calculators.Calculator{} = insert(:calculator))
  end

  @valid_attrs params_for(:calculator)

  @required_attributes [:iata_from, :iata_to, :city_from, :city_to, :original_distance]
  test "validates required attributes" do
    attrs = Map.drop(@valid_attrs, @required_attributes)

    changeset = Calculator.changeset(%Calculator{}, attrs)

    for attribute <- @required_attributes do
      assert %{^attribute => ["can't be blank"]} = errors_on(changeset)
    end
  end

  @attributes_with_length [:iata_from, :iata_to]
  test "validate length of attributes" do
    attrs =
      for attribute <- @attributes_with_length, into: @valid_attrs do
        {attribute, "LongLongString"}
      end

    changeset = Calculator.changeset(%Calculator{}, attrs)

    for attribute <- @attributes_with_length do
      assert %{^attribute => ["should be 3 character(s)"]} = errors_on(changeset)
    end
  end

  @protected_attributes [:city_from, :city_to, :original_distance, :airport_from, :airport_to]
  test "refuse protected attributes" do
    attrs =
      for attribute <- @protected_attributes, into: @valid_attrs do
        {attribute, "You shall not pass"}
      end

    changeset = Calculator.changeset(%Calculator{}, attrs)

    for attribute <- @protected_attributes do
      assert %{^attribute => ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "when input is correct" do
    setup do
      airport_from = insert(:airport, city: "Minsk")
      airport_to = insert(:airport, city: "Moscow")

      {:ok, airport_from: airport_from, airport_to: airport_to}
    end

    test "returns valid changeset", %{airport_from: airport_from, airport_to: airport_to} do
      city_from = airport_from.city
      city_to = airport_to.city
      iata_from = airport_from.iata
      iata_to = airport_to.iata

      attrs = %{iata_from: iata_from, iata_to: iata_to}

      changeset = Calculator.changeset(%Calculator{}, attrs)

      assert(
        %Ecto.Changeset{
          valid?: true,
          changes: %{
            city_from: ^city_from,
            city_to: ^city_to,
            iata_from: ^iata_from,
            iata_to: ^iata_to,
            airport_from: ^airport_from,
            airport_to: ^airport_to,
            original_distance: 0
          }
        } = changeset
      )
    end
  end

  describe "when input iata_from is incorrect" do
    setup do
      airport_from = insert(:airport)
      airport_to = insert(:airport)

      {:ok, airport_from: airport_from, airport_to: airport_to}
    end

    test "with invalid iata_from", %{airport_to: airport_to} do
      iata_from = "🤷‍♀️🤷‍♀️🤷‍♀️"
      iata_to = airport_to.iata

      attrs = %{iata_from: iata_from, iata_to: iata_to}
      changeset = Calculator.changeset(%Calculator{}, attrs)

      assert(
        %{
          airport_from: ["can't be blank"],
          city_from: ["can't be blank"],
          city_to: ["can't be blank"],
          original_distance: ["can't be blank"]
        } = errors_on(changeset)
      )

      refute(errors_on(changeset)[:airport_to] == ["can't be blank"])
    end

    test "with invalid iata_to", %{airport_from: airport_from} do
      iata_from = airport_from.iata
      iata_to = "🤷‍♂️🤷‍♂️🤷‍♂️"

      attrs = %{iata_from: iata_from, iata_to: iata_to}
      changeset = Calculator.changeset(%Calculator{}, attrs)

      assert(
        %{
          airport_to: ["can't be blank"],
          city_from: ["can't be blank"],
          city_to: ["can't be blank"],
          original_distance: ["can't be blank"]
        } = errors_on(changeset)
      )

      refute(errors_on(changeset)[:airport_from] == ["can't be blank"])
    end
  end
end
