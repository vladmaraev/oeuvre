defmodule Oeuvre.StimuliTest do
  use Oeuvre.DataCase

  alias Oeuvre.Stimuli

  describe "images" do
    alias Oeuvre.Stimuli.Image

    import Oeuvre.StimuliFixtures

    @invalid_attrs %{filename: nil}

    test "list_images/0 returns all images" do
      image = image_fixture()
      assert Stimuli.list_images() == [image]
    end

    test "get_image!/1 returns the image with given id" do
      image = image_fixture()
      assert Stimuli.get_image!(image.id) == image
    end

    test "create_image/1 with valid data creates a image" do
      valid_attrs = %{filename: "some filename"}

      assert {:ok, %Image{} = image} = Stimuli.create_image(valid_attrs)
      assert image.filename == "some filename"
    end

    test "create_image/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stimuli.create_image(@invalid_attrs)
    end

    test "update_image/2 with valid data updates the image" do
      image = image_fixture()
      update_attrs = %{filename: "some updated filename"}

      assert {:ok, %Image{} = image} = Stimuli.update_image(image, update_attrs)
      assert image.filename == "some updated filename"
    end

    test "update_image/2 with invalid data returns error changeset" do
      image = image_fixture()
      assert {:error, %Ecto.Changeset{}} = Stimuli.update_image(image, @invalid_attrs)
      assert image == Stimuli.get_image!(image.id)
    end

    test "delete_image/1 deletes the image" do
      image = image_fixture()
      assert {:ok, %Image{}} = Stimuli.delete_image(image)
      assert_raise Ecto.NoResultsError, fn -> Stimuli.get_image!(image.id) end
    end

    test "change_image/1 returns a image changeset" do
      image = image_fixture()
      assert %Ecto.Changeset{} = Stimuli.change_image(image)
    end
  end
end
