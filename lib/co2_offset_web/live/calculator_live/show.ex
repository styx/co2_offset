defmodule Co2OffsetWeb.CalculatorLive.Show do
  use Phoenix.LiveView
  alias Co2Offset.Calculators
  alias Co2Offset.Converters
  alias Co2Offset.Geo
  alias Phoenix.LiveView.Socket

  def render(assigns) do
    Co2OffsetWeb.CalculatorView.render("show.html", assigns)
  end

  def mount(%{path_params: %{"id" => id}}, socket) do
    new_socket =
      socket
      |> assign(id: id)
      |> assign_calculator()
      |> assign_original_converters()
      |> assign_original_co2()
      |> assign_similar_distances()

    {:ok, new_socket}
  end

  def handle_event("increase_donation", _params, socket) do
    new_socket =
      socket
      |> assign_donation_converters(+5)
      |> assign_similar_distances

    {:noreply, new_socket}
  end

  def handle_event("decrease_donation", _params, socket) do
    new_socket =
      socket
      |> assign_donation_converters(-5)
      |> assign_similar_distances

    {:noreply, new_socket}
  end

  defp assign_donation_converters(%Socket{assigns: %{original_co2: original_co2, converters: %{money: %{dollar: previous_money}}}} = socket, diff) do
    new_donation = max(5, previous_money + diff)
    converters = Converters.from_donation(original_co2, new_donation)

    assign(socket, converters: converters)
  end

  defp assign_calculator(%Socket{assigns: %{id: id}} = socket) do
    calculator = Calculators.get_calculator!(id)

    assign(socket, calculator: calculator)
  end

  defp assign_original_converters(%Socket{assigns: %{calculator: calculator}} = socket) do
    converters = Converters.from_plane(calculator.original_distance)

    assign(socket, converters: converters)
  end

  defp assign_original_co2(%Socket{assigns: %{converters: %{co2: co2}}} = socket) do
    assign(socket, original_co2: co2)
  end

  defp assign_similar_distances(%Socket{assigns: %{converters: converters}} = socket) do
    new_converters =
      converters
      |> Map.update!(:car, &put_distance_examples/1)
      |> Map.update!(:train, &put_distance_examples/1)
      |> Map.update(:additional_plane, nil, &put_distance_examples/1)

    assign(socket, converters: new_converters)
  end

  defp put_distance_examples(converter) do
    %{from: location_from, to: location_to} =
      Geo.get_locations_with_similar_distance(converter[:km])

    converter
    |> Map.put(:example_from, location_from)
    |> Map.put(:example_to, location_to)
  end
end
