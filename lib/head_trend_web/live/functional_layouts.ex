defmodule HeadTrendWeb.FunctionalLayouts do
  use HeadTrendWeb, :live_view

  alias HeadTrendWeb.FunctionalLayoutComponents

  @impl true
  def mount(_params, _session, socket) do
    words =
      String.split(
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
      )

    max_length = min(5, length(words))

    phrases =
      for _ <- 1..11 do
        Enum.take(words, Enum.random(1..max_length))
        |> Enum.join(" ")
      end

    {:ok,
     socket
     |> assign(:lorem, phrases)
     |> assign(:mygap_value, 1)
     |> assign(:myrange_value, 50)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.input
        label="Width"
        name="myrange"
        id="myrange"
        type="range"
        min="10"
        max="100"
        value={@myrange_value}
        phx-throttle
        phx-click="myrange_change"
      />
      <.input
        label="Gap"
        name="mygap"
        id="mygap"
        type="range"
        min="0"
        max="8"
        value={@mygap_value}
        phx-throttle
        phx-click="mygap_change"
      />
    </div>

    <div id="mycontainer" class="bg-slate-400 mx-auto divide-y-2" style={"width:#{@myrange_value}%"}>
      <details>
        <summary>
          Auto Grid
        </summary>
        
        <FunctionalLayoutComponents.auto_grid gap={"#{@mygap_value}rem"} min_col_size="12rem">
          <div :for={content <- @lorem} class="border border-solid border-black">
            <%= content %>
          </div>
        </FunctionalLayoutComponents.auto_grid>
      </details>
      
      <details open>
        <summary>
          Flex Grid
        </summary>
        
        <FunctionalLayoutComponents.flex_grid gap={"#{@mygap_value}rem"}>
          <:item :for={content <- @lorem}>
            <div class="border border-solid border-black"><%= content %></div>
          </:item>
        </FunctionalLayoutComponents.flex_grid>
      </details>
      
      <details open>
        <summary>
          Flex Group
        </summary>
        
        <FunctionalLayoutComponents.flex_group gap="1rem">
          <div :for={content <- @lorem} class="border border-solid border-black">
            <%= content %>
          </div>
        </FunctionalLayoutComponents.flex_group>
      </details>
    </div>
    """
  end

  @impl true
  def handle_event("myrange_change", %{"value" => myrange_value}, socket) do
    {:noreply, assign(socket, :myrange_value, myrange_value)}
  end

  @impl true
  def handle_event("mygap_change", %{"value" => mygap_value}, socket) do
    {:noreply, assign(socket, :mygap_value, mygap_value)}
  end
end
