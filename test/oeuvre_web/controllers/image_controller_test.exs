defmodule OeuvreWeb.ImageControllerTest do
  use OeuvreWeb.ConnCase

  import Oeuvre.StimuliFixtures

  @create_attrs %{filename: "some filename"}
  @update_attrs %{filename: "some updated filename"}
  @invalid_attrs %{filename: nil}

  describe "index" do
    test "lists all images", %{conn: conn} do
      conn = get(conn, ~p"/images")
      assert html_response(conn, 200) =~ "Listing Images"
    end
  end

  describe "new image" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/images/new")
      assert html_response(conn, 200) =~ "New Image"
    end
  end

  describe "create image" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/images", image: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/images/#{id}"

      conn = get(conn, ~p"/images/#{id}")
      assert html_response(conn, 200) =~ "Image #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/images", image: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Image"
    end
  end

  describe "edit image" do
    setup [:create_image]

    test "renders form for editing chosen image", %{conn: conn, image: image} do
      conn = get(conn, ~p"/images/#{image}/edit")
      assert html_response(conn, 200) =~ "Edit Image"
    end
  end

  describe "update image" do
    setup [:create_image]

    test "redirects when data is valid", %{conn: conn, image: image} do
      conn = put(conn, ~p"/images/#{image}", image: @update_attrs)
      assert redirected_to(conn) == ~p"/images/#{image}"

      conn = get(conn, ~p"/images/#{image}")
      assert html_response(conn, 200) =~ "some updated filename"
    end

    test "renders errors when data is invalid", %{conn: conn, image: image} do
      conn = put(conn, ~p"/images/#{image}", image: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Image"
    end
  end

  describe "delete image" do
    setup [:create_image]

    test "deletes chosen image", %{conn: conn, image: image} do
      conn = delete(conn, ~p"/images/#{image}")
      assert redirected_to(conn) == ~p"/images"

      assert_error_sent 404, fn ->
        get(conn, ~p"/images/#{image}")
      end
    end
  end

  defp create_image(_) do
    image = image_fixture()
    %{image: image}
  end
end
