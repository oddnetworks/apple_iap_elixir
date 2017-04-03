defmodule AppleIAP do
  @moduledoc """
  Documentation for AppleIAP.
  """

  alias AppleIAP.Client

  @doc """
  Updates a previous transaction with a new billing cycle date

  Args:
    * `receipt_data` - The base64 encoded receipt data
    * `password`- Your app's shared secret
  """
  @spec verify_receipt(atom, String.t, String.t) :: HTTPoison.Response
  def verify_receipt(:sandbox, password, receipt_data) do
    body = %{
        "receipt-data": receipt_data,
        "password": password
      }

    Client.post("https://sandbox.itunes.apple.com/verifyReceipt", body, [{"content-type", "application/json"}])
  end

  @doc """
  Updates a previous transaction with a new billing cycle date

  Args:
    * `receipt_data` - The base64 encoded receipt data
    * `password`- Your app's shared secret
  """
  @spec verify_receipt(String.t, String.t) :: HTTPoison.Response
  def verify_receipt(password, receipt_data) do
    body = %{
        "receipt-data": receipt_data,
        "password": password
      }

    Client.post("https://buy.itunes.apple.com/verifyReceipt", body, [{"content-type", "application/json"}])
  end
end
