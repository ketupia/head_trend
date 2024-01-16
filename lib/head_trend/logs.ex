defmodule HeadTrend.Logs do
  @moduledoc """
  The Logs context.
  """

  import Ecto.Query, warn: false
  alias HeadTrend.Repo

  alias HeadTrend.Logs.LogEntry

  @doc """
  Returns the list of log_entries.

  ## Examples

      iex> list_log_entries()
      [%LogEntry{}, ...]

  """
  def list_log_entries(user_id) do
    Repo.all(
      from le in LogEntry,
        where: le.user_id == ^user_id,
        order_by: [desc: le.occurred_on]
    )
  end

  @doc """
  Gets a single log_entry.

  Raises `Ecto.NoResultsError` if the Log entry does not exist.

  ## Examples

      iex> get_log_entry!(123)
      %LogEntry{}

      iex> get_log_entry!(456)
      ** (Ecto.NoResultsError)

  """
  def get_log_entry!(id), do: Repo.get!(LogEntry, id)

  @doc """
  Creates a log_entry.

  ## Examples

      iex> create_log_entry(%{field: value})
      {:ok, %LogEntry{}}

      iex> create_log_entry(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_log_entry(attrs \\ %{}) do
    %LogEntry{}
    |> LogEntry.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a log_entry.

  ## Examples

      iex> update_log_entry(log_entry, %{field: new_value})
      {:ok, %LogEntry{}}

      iex> update_log_entry(log_entry, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_log_entry(%LogEntry{} = log_entry, attrs) do
    log_entry
    |> LogEntry.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a log_entry.

  ## Examples

      iex> delete_log_entry(log_entry)
      {:ok, %LogEntry{}}

      iex> delete_log_entry(log_entry)
      {:error, %Ecto.Changeset{}}

  """
  def delete_log_entry(%LogEntry{} = log_entry) do
    Repo.delete(log_entry)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking log_entry changes.

  ## Examples

      iex> change_log_entry(log_entry)
      %Ecto.Changeset{data: %LogEntry{}}

  """
  def change_log_entry(%LogEntry{} = log_entry, attrs \\ %{}) do
    LogEntry.changeset(log_entry, attrs)
  end
end
