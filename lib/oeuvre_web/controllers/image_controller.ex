defmodule OeuvreWeb.ImageController do
  use OeuvreWeb, :controller

  alias Oeuvre.Stimuli
  alias Oeuvre.Stimuli.Image

  def index(conn, _params) do
    images = Stimuli.list_images()
    render(conn, :index, images: images)
  end

  def new(conn, _params) do
    changeset = Stimuli.change_image(%Image{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"image" => image_params}) do
    case Stimuli.create_image(image_params) do
      {:ok, image} ->
        conn
        |> put_flash(:info, "Image created successfully.")
        |> redirect(to: ~p"/images/")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    image = Stimuli.get_image!(id)
    render(conn, :show, image: image)
  end

  def edit(conn, %{"id" => id}) do
    image = Stimuli.get_image!(id)
    changeset = Stimuli.change_image(image)
    render(conn, :edit, image: image, changeset: changeset)
  end

  def update(conn, %{"id" => id, "image" => image_params}) do
    image = Stimuli.get_image!(id)

    case Stimuli.update_image(image, image_params) do
      {:ok, image} ->
        conn
        |> put_flash(:info, "Image updated successfully.")
        |> redirect(to: ~p"/images/#{image}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, image: image, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    image = Stimuli.get_image!(id)
    {:ok, _image} = Stimuli.delete_image(image)

    conn
    |> put_flash(:info, "Image deleted successfully.")
    |> redirect(to: ~p"/images")
  end
end
