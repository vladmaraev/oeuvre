defmodule Oeuvre.SessionsTest do
  use Oeuvre.DataCase

  alias Oeuvre.Sessions

  describe "sessions" do
    alias Oeuvre.Sessions.Session

    import Oeuvre.SessionsFixtures

    @invalid_attrs %{}

    test "list_sessions/0 returns all sessions" do
      session = session_fixture()
      assert Sessions.list_sessions() == [session]
    end

    test "get_session!/1 returns the session with given id" do
      session = session_fixture()
      assert Sessions.get_session!(session.id) == session
    end

    test "create_session/1 with valid data creates a session" do
      valid_attrs = %{}

      assert {:ok, %Session{} = session} = Sessions.create_session(valid_attrs)
    end

    test "create_session/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sessions.create_session(@invalid_attrs)
    end

    test "update_session/2 with valid data updates the session" do
      session = session_fixture()
      update_attrs = %{}

      assert {:ok, %Session{} = session} = Sessions.update_session(session, update_attrs)
    end

    test "update_session/2 with invalid data returns error changeset" do
      session = session_fixture()
      assert {:error, %Ecto.Changeset{}} = Sessions.update_session(session, @invalid_attrs)
      assert session == Sessions.get_session!(session.id)
    end

    test "delete_session/1 deletes the session" do
      session = session_fixture()
      assert {:ok, %Session{}} = Sessions.delete_session(session)
      assert_raise Ecto.NoResultsError, fn -> Sessions.get_session!(session.id) end
    end

    test "change_session/1 returns a session changeset" do
      session = session_fixture()
      assert %Ecto.Changeset{} = Sessions.change_session(session)
    end
  end

  describe "sessions" do
    alias Oeuvre.Sessions.Session

    import Oeuvre.SessionsFixtures

    @invalid_attrs %{prolific_id: nil, prolific_session_id: nil, prolific_study_id: nil, group_id: nil}

    test "list_sessions/0 returns all sessions" do
      session = session_fixture()
      assert Sessions.list_sessions() == [session]
    end

    test "get_session!/1 returns the session with given id" do
      session = session_fixture()
      assert Sessions.get_session!(session.id) == session
    end

    test "create_session/1 with valid data creates a session" do
      valid_attrs = %{prolific_id: "some prolific_id", prolific_session_id: "some prolific_session_id", prolific_study_id: "some prolific_study_id", group_id: 42}

      assert {:ok, %Session{} = session} = Sessions.create_session(valid_attrs)
      assert session.prolific_id == "some prolific_id"
      assert session.prolific_session_id == "some prolific_session_id"
      assert session.prolific_study_id == "some prolific_study_id"
      assert session.group_id == 42
    end

    test "create_session/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sessions.create_session(@invalid_attrs)
    end

    test "update_session/2 with valid data updates the session" do
      session = session_fixture()
      update_attrs = %{prolific_id: "some updated prolific_id", prolific_session_id: "some updated prolific_session_id", prolific_study_id: "some updated prolific_study_id", group_id: 43}

      assert {:ok, %Session{} = session} = Sessions.update_session(session, update_attrs)
      assert session.prolific_id == "some updated prolific_id"
      assert session.prolific_session_id == "some updated prolific_session_id"
      assert session.prolific_study_id == "some updated prolific_study_id"
      assert session.group_id == 43
    end

    test "update_session/2 with invalid data returns error changeset" do
      session = session_fixture()
      assert {:error, %Ecto.Changeset{}} = Sessions.update_session(session, @invalid_attrs)
      assert session == Sessions.get_session!(session.id)
    end

    test "delete_session/1 deletes the session" do
      session = session_fixture()
      assert {:ok, %Session{}} = Sessions.delete_session(session)
      assert_raise Ecto.NoResultsError, fn -> Sessions.get_session!(session.id) end
    end

    test "change_session/1 returns a session changeset" do
      session = session_fixture()
      assert %Ecto.Changeset{} = Sessions.change_session(session)
    end
  end
end
