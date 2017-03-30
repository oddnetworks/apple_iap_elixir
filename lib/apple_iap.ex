defmodule AppleIAP do
  @moduledoc """
  Documentation for AppleIAP.
  """

  alias AppleIAP.Client

  @doc """
  Updates a previous transaction with a new billing cycle date

  Args:
    * `env` - :sandbox or :production
    * `receipt_data` - The base64 encoded receipt data
    * `password`- Your app's shared secret
  """
  @spec verify_receipt(atom, String.t, String.t) :: HTTPoison.Response
  def verify_receipt(env, password, receipt_data) do
    body = %{
        "receipt-data": receipt_data,
        "password": password
      }

    environment_url(env) <> "/verifyReceipt"
    |> Client.post(body, [{"content-type", "application/json"}])
  end

  defp environment_url(env) do
    case env do
      :sandbox -> "https://sandbox.itunes.apple.com"
      _default -> "https://buy.itunes.apple.com"
    end
  end
end
