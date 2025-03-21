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
      |> Enum.into(%{

      })
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
end
