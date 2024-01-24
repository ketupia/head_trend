defmodule HeadTrendWeb.FunctionalLayoutComponents do
  use Phoenix.Component

  @doc """
  Provides a handle that enables the user to resize the contents
  """
  slot :inner_block, doc: "the content to be resized"

  def resizable(assigns) do
    ~H"""
    <div class="resize border-2 border-solid p-2 overflow-auto">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  auto-grid Creates a horizontal flow of children that will wrap.  Each child is the same width.
  """
  slot :inner_block, doc: "the content to be arranged in the grid"

  attr :gap, :string,
    default: "1rem",
    doc: "specifies the size of the gap between items both horizontally and vertically."

  attr :min_col_size, :string,
    default: "8rem",
    doc: "specifies the minimum width of each item."

  attr :class, :string, default: nil, doc: "classes to add  to the grid container"
  attr :rest, :global, doc: "any other attributes will be appended to the grid container"

  def auto_grid(assigns) do
    ~H"""
    <div
      class={["grid", @class]}
      style={"gap:#{@gap}; grid-template-columns:repeat(auto-fit, minmax(min(#{@min_col_size}, 100%), 1fr))"}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
    flex-grid creates a horizontal flow of children that will wrap.
  Children on the last line will expand to fill space.
  """
  slot :item, doc: "some content to be arranged in the grid"

  attr :gap, :string,
    default: "1rem",
    doc: "specifies the size of the gap between items both horizontally and vertically."

  attr :class, :string, default: nil, doc: "classes to add  to the grid container"
  attr :rest, :global, doc: "any other attributes will be appended to the grid container"

  def flex_grid(assigns) do
    ~H"""
    <div class={["flex flex-wrap", @class]} style={"gap:#{@gap};"} {@rest}>
      <div :for={itm <- @item} class="flex-1">
        <%= render_slot(itm) %>
      </div>
    </div>
    """
  end

  slot :inner_block, doc: "the content to be arranged in the group"

  attr :gap, :string,
    default: "1rem",
    doc: "specifies the size of the gap between items both horizontally and vertically."

  attr :class, :string, default: nil, doc: "classes to add  to the grid container"
  attr :rest, :global, doc: "any other attributes will be appended to the grid container"

  def flex_group(assigns) do
    ~H"""
    <div class={["flex flex-wrap", @class]} style={"gap:#{@gap};"} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
