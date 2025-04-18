defmodule Oeuvre.Sessions do
  @moduledoc """
  The Sessions context.
  """

  import Ecto.Query, warn: false
  alias Oeuvre.Repo

  alias Oeuvre.Sessions.Session

  @doc """
  Returns the list of sessions.

  ## Examples

      iex> list_sessions()
      [%Session{}, ...]

  """
  def list_sessions do
    Repo.all(Session)
  end

  @doc """
  Gets a single session.

  Raises `Ecto.NoResultsError` if the Session does not exist.

  ## Examples

      iex> get_session!(123)
      %Session{}

      iex> get_session!(456)
      ** (Ecto.NoResultsError)

  """
  def get_session!(id), do: Repo.get!(Session, id)

  @doc """
  Returns prolific session by participant if it exists.
  """
  def get_prolific_session(prolific_pid) do
    Repo.one(from s in Session, where: s.prolific_pid == ^prolific_pid)
  end

  @doc """
  Creates a session.

  ## Examples

      iex> create_session(%{field: value})
      {:ok, %Session{}}

      iex> create_session(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_session(attrs \\ %{}) do
    %Session{}
    |> Session.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a session.

  ## Examples

      iex> update_session(session, %{field: new_value})
      {:ok, %Session{}}

      iex> update_session(session, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_session(%Session{} = session, attrs) do
    session
    |> Session.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a session.

  ## Examples

      iex> delete_session(session)
      {:ok, %Session{}}

      iex> delete_session(session)
      {:error, %Ecto.Changeset{}}

  """
  def delete_session(%Session{} = session) do
    Repo.delete(session)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking session changes.

  ## Examples

      iex> change_session(session)
      %Ecto.Changeset{data: %Session{}}

  """
  def change_session(%Session{} = session, attrs \\ %{}) do
    Session.changeset(session, attrs)
  end

  alias Oeuvre.Sessions.AllowedPid

  @doc """
  Returns the list of allowed_pids.

  ## Examples

      iex> list_allowed_pids()
      [%AllowedPid{}, ...]

  """
  def list_allowed_pids do
    Repo.all(AllowedPid)
  end

  @doc """
  Gets a single allowed_pid.

  Raises `Ecto.NoResultsError` if the Allowed pid does not exist.

  ## Examples

      iex> get_allowed_pid!(123)
      %AllowedPid{}

      iex> get_allowed_pid!(456)
      ** (Ecto.NoResultsError)

  """
  def get_allowed_pid!(id), do: Repo.get!(AllowedPid, id)

  @doc """
  Creates a allowed_pid.

  ## Examples

      iex> create_allowed_pid(%{field: value})
      {:ok, %AllowedPid{}}

      iex> create_allowed_pid(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_allowed_pid(attrs \\ %{}) do
    %AllowedPid{}
    |> AllowedPid.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a allowed_pid.

  ## Examples

      iex> update_allowed_pid(allowed_pid, %{field: new_value})
      {:ok, %AllowedPid{}}

      iex> update_allowed_pid(allowed_pid, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_allowed_pid(%AllowedPid{} = allowed_pid, attrs) do
    allowed_pid
    |> AllowedPid.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a allowed_pid.

  ## Examples

      iex> delete_allowed_pid(allowed_pid)
      {:ok, %AllowedPid{}}

      iex> delete_allowed_pid(allowed_pid)
      {:error, %Ecto.Changeset{}}

  """
  def delete_allowed_pid(%AllowedPid{} = allowed_pid) do
    Repo.delete(allowed_pid)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking allowed_pid changes.

  ## Examples

      iex> change_allowed_pid(allowed_pid)
      %Ecto.Changeset{data: %AllowedPid{}}

  """
  def change_allowed_pid(%AllowedPid{} = allowed_pid, attrs \\ %{}) do
    AllowedPid.changeset(allowed_pid, attrs)
  end

  alias Oeuvre.Sessions.Transcript

  @doc """
  Returns the list of transcripts.

  ## Examples

      iex> list_transcripts()
      [%Transcript{}, ...]

  """
  def list_transcripts do
    Repo.all(Transcript)
  end

  @doc """
  Gets a single transcript.

  Raises `Ecto.NoResultsError` if the Transcript does not exist.

  ## Examples

      iex> get_transcript!(123)
      %Transcript{}

      iex> get_transcript!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transcript!(id), do: Repo.get!(Transcript, id)

  @doc """
  Creates a transcript.

  ## Examples

      iex> create_transcript(%{field: value})
      {:ok, %Transcript{}}

      iex> create_transcript(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transcript(attrs \\ %{}) do
    %Transcript{}
    |> Transcript.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a transcript.

  ## Examples

      iex> update_transcript(transcript, %{field: new_value})
      {:ok, %Transcript{}}

      iex> update_transcript(transcript, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transcript(%Transcript{} = transcript, attrs) do
    transcript
    |> Transcript.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a transcript.

  ## Examples

      iex> delete_transcript(transcript)
      {:ok, %Transcript{}}

      iex> delete_transcript(transcript)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transcript(%Transcript{} = transcript) do
    Repo.delete(transcript)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transcript changes.

  ## Examples

      iex> change_transcript(transcript)
      %Ecto.Changeset{data: %Transcript{}}

  """
  def change_transcript(%Transcript{} = transcript, attrs \\ %{}) do
    Transcript.changeset(transcript, attrs)
  end
end
