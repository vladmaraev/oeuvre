defmodule Oeuvre.SessionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Oeuvre.Sessions` context.
  """

  @doc """
  Generate a session.
  """
  def session_fixture(attrs \\ %{}) do
    {:ok, session} =
      attrs
      |> Enum.into(%{})
      |> Oeuvre.Sessions.create_session()

    session
  end

  @doc """
  Generate a session.
  """
  def session_fixture(attrs \\ %{}) do
    {:ok, session} =
      attrs
      |> Enum.into(%{
        group_id: 42,
        prolific_id: "some prolific_id",
        prolific_session_id: "some prolific_session_id",
        prolific_study_id: "some prolific_study_id"
      })
      |> Oeuvre.Sessions.create_session()

    session
  end

  @doc """
  Generate a allowed_pid.
  """
  def allowed_pid_fixture(attrs \\ %{}) do
    {:ok, allowed_pid} =
      attrs
      |> Enum.into(%{
        prolific_pid: "some prolific_pid"
      })
      |> Oeuvre.Sessions.create_allowed_pid()

    allowed_pid
  end

  @doc """
  Generate a transcript.
  """
  def transcript_fixture(attrs \\ %{}) do
    {:ok, transcript} =
      attrs
      |> Enum.into(%{
        moves: [],
        session_id: 42
      })
      |> Oeuvre.Sessions.create_transcript()

    transcript
  end
end
