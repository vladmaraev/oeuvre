defmodule OeuvreWeb.AssessmentController do
  use OeuvreWeb, :controller

  alias Oeuvre.Assessments
  alias Oeuvre.Assessments.Assessment

  def new(conn, %{trial: trial}) do
    changeset = Assessments.change_assessment(%Assessment{})
    render(conn, :new, changeset: changeset)
  end
end
