defmodule AppleIAP.Client do
  use HTTPoison.Base

  defp process_url(url) do
    url
  end

  defp process_response_body(body) do
    body
    |> Poison.decode!
  end

  defp process_request_body(body) do
    case body do
      "" -> body
      _ -> body |> Poison.encode!
    end
  end

  defp process_request_headers(headers) do
    [{"accept", "application/json"} | headers]
  end
end