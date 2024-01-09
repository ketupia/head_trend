defmodule HeadTrendWeb.LogEntryLiveTest do
  use HeadTrendWeb.ConnCase

  import Phoenix.LiveViewTest
  import HeadTrend.LogsFixtures

  @create_attrs %{
    occurred_on: "2023-12-30T16:58:00Z",
    headache: true,
    fever: true,
    pain_reliever: "some pain_reliever"
  }
  @update_attrs %{
    occurred_on: "2023-12-31T16:58:00Z",
    headache: false,
    fever: false,
    pain_reliever: "some updated pain_reliever"
  }
  @invalid_attrs %{occurred_on: nil, headache: false, fever: false, pain_reliever: nil}

  defp create_log_entry(_) do
    log_entry = log_entry_fixture()
    %{log_entry: log_entry}
  end

  describe "Index" do
    setup [:create_log_entry]

    test "lists all log_entries", %{conn: conn, log_entry: log_entry} do
      {:ok, _index_live, html} = live(conn, ~p"/log_entries")

      assert html =~ "Listing Log entries"
      assert html =~ log_entry.pain_reliever
    end

    test "saves new log_entry", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/log_entries")

      assert index_live |> element("a", "New Log entry") |> render_click() =~
               "New Log entry"

      assert_patch(index_live, ~p"/log_entries/new")

      assert index_live
             |> form("#log_entry-form", log_entry: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#log_entry-form", log_entry: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/log_entries")

      html = render(index_live)
      assert html =~ "Log entry created successfully"
      assert html =~ "some pain_reliever"
    end

    test "updates log_entry in listing", %{conn: conn, log_entry: log_entry} do
      {:ok, index_live, _html} = live(conn, ~p"/log_entries")

      assert index_live |> element("#log_entries-#{log_entry.id} a", "Edit") |> render_click() =~
               "Edit Log entry"

      assert_patch(index_live, ~p"/log_entries/#{log_entry}/edit")

      assert index_live
             |> form("#log_entry-form", log_entry: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#log_entry-form", log_entry: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/log_entries")

      html = render(index_live)
      assert html =~ "Log entry updated successfully"
      assert html =~ "some updated pain_reliever"
    end

    test "deletes log_entry in listing", %{conn: conn, log_entry: log_entry} do
      {:ok, index_live, _html} = live(conn, ~p"/log_entries")

      assert index_live |> element("#log_entries-#{log_entry.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#log_entries-#{log_entry.id}")
    end
  end

  describe "Show" do
    setup [:create_log_entry]

    test "displays log_entry", %{conn: conn, log_entry: log_entry} do
      {:ok, _show_live, html} = live(conn, ~p"/log_entries/#{log_entry}")

      assert html =~ "Show Log entry"
      assert html =~ log_entry.pain_reliever
    end

    test "updates log_entry within modal", %{conn: conn, log_entry: log_entry} do
      {:ok, show_live, _html} = live(conn, ~p"/log_entries/#{log_entry}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Log entry"

      assert_patch(show_live, ~p"/log_entries/#{log_entry}/show/edit")

      assert show_live
             |> form("#log_entry-form", log_entry: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#log_entry-form", log_entry: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/log_entries/#{log_entry}")

      html = render(show_live)
      assert html =~ "Log entry updated successfully"
      assert html =~ "some updated pain_reliever"
    end
  end
end
