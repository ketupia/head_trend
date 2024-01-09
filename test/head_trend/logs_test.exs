defmodule HeadTrend.LogsTest do
  use HeadTrend.DataCase

  alias HeadTrend.Logs

  describe "log_entries" do
    alias HeadTrend.Logs.LogEntry

    import HeadTrend.LogsFixtures

    @invalid_attrs %{occurred_on: nil, headache: nil, fever: nil, pain_reliever: nil}

    test "list_log_entries/0 returns all log_entries" do
      log_entry = log_entry_fixture()
      assert Logs.list_log_entries() == [log_entry]
    end

    test "get_log_entry!/1 returns the log_entry with given id" do
      log_entry = log_entry_fixture()
      assert Logs.get_log_entry!(log_entry.id) == log_entry
    end

    test "create_log_entry/1 with valid data creates a log_entry" do
      valid_attrs = %{
        occurred_on: ~U[2023-12-30 16:58:00Z],
        headache: true,
        fever: true,
        pain_reliever: "some pain_reliever"
      }

      assert {:ok, %LogEntry{} = log_entry} = Logs.create_log_entry(valid_attrs)
      assert log_entry.occurred_on == ~U[2023-12-30 16:58:00Z]
      assert log_entry.headache == true
      assert log_entry.fever == true
      assert log_entry.pain_reliever == "some pain_reliever"
    end

    test "create_log_entry/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logs.create_log_entry(@invalid_attrs)
    end

    test "update_log_entry/2 with valid data updates the log_entry" do
      log_entry = log_entry_fixture()

      update_attrs = %{
        occurred_on: ~U[2023-12-31 16:58:00Z],
        headache: false,
        fever: false,
        pain_reliever: "some updated pain_reliever"
      }

      assert {:ok, %LogEntry{} = log_entry} = Logs.update_log_entry(log_entry, update_attrs)
      assert log_entry.occurred_on == ~U[2023-12-31 16:58:00Z]
      assert log_entry.headache == false
      assert log_entry.fever == false
      assert log_entry.pain_reliever == "some updated pain_reliever"
    end

    test "update_log_entry/2 with invalid data returns error changeset" do
      log_entry = log_entry_fixture()
      assert {:error, %Ecto.Changeset{}} = Logs.update_log_entry(log_entry, @invalid_attrs)
      assert log_entry == Logs.get_log_entry!(log_entry.id)
    end

    test "delete_log_entry/1 deletes the log_entry" do
      log_entry = log_entry_fixture()
      assert {:ok, %LogEntry{}} = Logs.delete_log_entry(log_entry)
      assert_raise Ecto.NoResultsError, fn -> Logs.get_log_entry!(log_entry.id) end
    end

    test "change_log_entry/1 returns a log_entry changeset" do
      log_entry = log_entry_fixture()
      assert %Ecto.Changeset{} = Logs.change_log_entry(log_entry)
    end
  end
end
