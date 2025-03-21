defmodule OeuvreWeb.AssessmentHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use OeuvreWeb, :html

  embed_templates "assessment_html/*"
end
