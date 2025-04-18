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

    @invalid_attrs %{
      prolific_id: nil,
      prolific_session_id: nil,
      prolific_study_id: nil,
      group_id: nil
    }

    test "list_sessions/0 returns all sessions" do
      session = session_fixture()
      assert Sessions.list_sessions() == [session]
    end

    test "get_session!/1 returns the session with given id" do
      session = session_fixture()
      assert Sessions.get_session!(session.id) == session
    end

    test "create_session/1 with valid data creates a session" do
      valid_attrs = %{
        prolific_id: "some prolific_id",
        prolific_session_id: "some prolific_session_id",
        prolific_study_id: "some prolific_study_id",
        group_id: 42
      }

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

      update_attrs = %{
        prolific_id: "some updated prolific_id",
        prolific_session_id: "some updated prolific_session_id",
        prolific_study_id: "some updated prolific_study_id",
        group_id: 43
      }

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

  describe "allowed_pids" do
    alias Oeuvre.Sessions.AllowedPid

    import Oeuvre.SessionsFixtures

    @invalid_attrs %{prolific_pid: nil}

    test "list_allowed_pids/0 returns all allowed_pids" do
      allowed_pid = allowed_pid_fixture()
      assert Sessions.list_allowed_pids() == [allowed_pid]
    end

    test "get_allowed_pid!/1 returns the allowed_pid with given id" do
      allowed_pid = allowed_pid_fixture()
      assert Sessions.get_allowed_pid!(allowed_pid.id) == allowed_pid
    end

    test "create_allowed_pid/1 with valid data creates a allowed_pid" do
      valid_attrs = %{prolific_pid: "some prolific_pid"}

      assert {:ok, %AllowedPid{} = allowed_pid} = Sessions.create_allowed_pid(valid_attrs)
      assert allowed_pid.prolific_pid == "some prolific_pid"
    end

    test "create_allowed_pid/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sessions.create_allowed_pid(@invalid_attrs)
    end

    test "update_allowed_pid/2 with valid data updates the allowed_pid" do
      allowed_pid = allowed_pid_fixture()
      update_attrs = %{prolific_pid: "some updated prolific_pid"}

      assert {:ok, %AllowedPid{} = allowed_pid} =
               Sessions.update_allowed_pid(allowed_pid, update_attrs)

      assert allowed_pid.prolific_pid == "some updated prolific_pid"
    end

    test "update_allowed_pid/2 with invalid data returns error changeset" do
      allowed_pid = allowed_pid_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Sessions.update_allowed_pid(allowed_pid, @invalid_attrs)

      assert allowed_pid == Sessions.get_allowed_pid!(allowed_pid.id)
    end

    test "delete_allowed_pid/1 deletes the allowed_pid" do
      allowed_pid = allowed_pid_fixture()
      assert {:ok, %AllowedPid{}} = Sessions.delete_allowed_pid(allowed_pid)
      assert_raise Ecto.NoResultsError, fn -> Sessions.get_allowed_pid!(allowed_pid.id) end
    end

    test "change_allowed_pid/1 returns a allowed_pid changeset" do
      allowed_pid = allowed_pid_fixture()
      assert %Ecto.Changeset{} = Sessions.change_allowed_pid(allowed_pid)
    end
  end

  describe "transcripts" do
    alias Oeuvre.Sessions.Transcript

    import Oeuvre.SessionsFixtures

    @invalid_attrs %{moves: nil, session_id: nil}

    test "list_transcripts/0 returns all transcripts" do
      transcript = transcript_fixture()
      assert Sessions.list_transcripts() == [transcript]
    end

    test "get_transcript!/1 returns the transcript with given id" do
      transcript = transcript_fixture()
      assert Sessions.get_transcript!(transcript.id) == transcript
    end

    test "create_transcript/1 with valid data creates a transcript" do
      valid_attrs = %{moves: [], session_id: 42}

      assert {:ok, %Transcript{} = transcript} = Sessions.create_transcript(valid_attrs)
      assert transcript.moves == []
      assert transcript.session_id == 42
    end

    test "create_transcript/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sessions.create_transcript(@invalid_attrs)
    end

    test "update_transcript/2 with valid data updates the transcript" do
      transcript = transcript_fixture()
      update_attrs = %{moves: [], session_id: 43}

      assert {:ok, %Transcript{} = transcript} = Sessions.update_transcript(transcript, update_attrs)
      assert transcript.moves == []
      assert transcript.session_id == 43
    end

    test "update_transcript/2 with invalid data returns error changeset" do
      transcript = transcript_fixture()
      assert {:error, %Ecto.Changeset{}} = Sessions.update_transcript(transcript, @invalid_attrs)
      assert transcript == Sessions.get_transcript!(transcript.id)
    end

    test "delete_transcript/1 deletes the transcript" do
      transcript = transcript_fixture()
      assert {:ok, %Transcript{}} = Sessions.delete_transcript(transcript)
      assert_raise Ecto.NoResultsError, fn -> Sessions.get_transcript!(transcript.id) end
    end

    test "change_transcript/1 returns a transcript changeset" do
      transcript = transcript_fixture()
      assert %Ecto.Changeset{} = Sessions.change_transcript(transcript)
    end
  end
end
