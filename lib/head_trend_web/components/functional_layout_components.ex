defmodule HeadTrendWeb.FunctionalLayoutComponents do
  use Phoenix.Component

  slot :inner_block

  def auto_grid(assigns) do
    ~H"""
    <div class="grid auto-cols-fr gap-4 ">
      <%= render_slot(@inner_block) %>
    </div>

    <div style="display:grid gap:1rem grid-template-columns:repeat(auto-fit, minmax(min(8rem, 100%), 1fr))">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
