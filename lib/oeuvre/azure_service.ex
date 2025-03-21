defmodule Oeuvre.AzureService do
  require Req

  defp azure_key, do: Application.fetch_env!(:oeuvre, Oeuvre.AzureService)[:key]

  def get_token do
    Req.post!("https://swedencentral.api.cognitive.microsoft.com/sts/v1.0/issueToken",
      headers: %{"Ocp-Apim-Subscription-Key": azure_key()},
      body: ""
    ).body
  end
end
