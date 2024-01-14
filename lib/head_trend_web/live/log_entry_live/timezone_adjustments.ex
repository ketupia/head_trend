defmodule HeadTrendWeb.LogEntryLive.TimezoneAdjustments do
  def utc_to_local(%DateTime{} = utc, timezone_offset) when is_integer(timezone_offset) do
    # IO.inspect(utc, label: "utc_to_local/2 utc")

    utc
    |> DateTime.to_naive()
    |> NaiveDateTime.add(timezone_offset, :minute)
  end

  @spec utc_to_local(map(), String.t() | atom(), Phoenix.LiveView.Socket.t()) :: map
  def utc_to_local(map, field, socket) do
    # IO.inspect(log_entry, label: "log_entry")

    if Map.has_key?(map, field) do
      timezone_offset = socket.assigns.timezone_offset

      utc = Map.get(map, field)
      # IO.inspect(utc, label: "utc_to_local/3 utc #{field}")

      local =
        utc_to_local(utc, timezone_offset)

      # IO.inspect(local, label: "utc_to_local/3 local #{field}")

      Map.put(map, field, local)
    else
      map
    end
  end

  def local_to_utc(local, timezone_offset) when is_integer(timezone_offset) do
    local = String.pad_trailing(local, 19, ":00")
    # IO.inspect(local, label: "local_to_utc local")

    with {:ok, utc, _tz} <-
           local
           |> NaiveDateTime.from_iso8601!()
           |> NaiveDateTime.add(-1 * timezone_offset, :minute)
           |> NaiveDateTime.to_iso8601()
           |> String.pad_trailing(20, "Z")
           |> DateTime.from_iso8601() do
      # IO.inspect(utc, label: "utc")
      utc
    end
  end

  @spec local_to_utc(map(), String.t() | atom(), Phoenix.LiveView.Socket.t()) :: map
  def local_to_utc(map, field, socket) do
    timezone_offset = socket.assigns.timezone_offset

    local = Map.get(map, field)
    # IO.inspect(local, label: "local_to_utc/3 local")

    utc = local_to_utc(local, timezone_offset)
    # IO.inspect(utc, label: "local_to_utc/3 utc")

    Map.put(map, field, utc)
  end
end
