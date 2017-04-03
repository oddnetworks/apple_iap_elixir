defmodule AppleIAP do
  @moduledoc """
  Documentation for AppleIAP.
  """

  alias AppleIAP.Client

  defmodule Receipt do
    defstruct(quantity: nil,
              product_id: nil,
              transaction_id: nil,
              original_transaction_id: nil,
              purchase_date: nil,
              original_purchase_date: nil,
              expires_date: nil,
              cancellation_date: nil,
              app_item_id: nil,
              version_external_identifier: nil,
              web_order_line_item_id: nil)
  end

  @doc """
  Updates a previous transaction with a new billing cycle date

  Args:
    * `receipt_data` - The base64 encoded receipt data
    * `password`- Your app's shared secret
  """
  @spec verify_receipt(atom, String.t, String.t) :: {:ok, Receipt.t | :error, String.t}
  def verify_receipt(:sandbox, password, receipt_data) do
    body = %{
        "receipt-data": receipt_data,
        "password": password
      }

    case do_post("https://sandbox.itunes.apple.com/verifyReceipt", body) do
      {:ok, response} -> to_receipt(response.body)
      {:error, error} -> {:error, error.reason}
    end
  end

  @doc """
  Updates a previous transaction with a new billing cycle date

  Args:
    * `receipt_data` - The base64 encoded receipt data
    * `password`- Your app's shared secret
  """
  @spec verify_receipt(String.t, String.t) :: {:ok, Receipt.t | :error, String.t}
  def verify_receipt(password, receipt_data) do
    body = %{
        "receipt-data": receipt_data,
        "password": password
      }

    case do_post("https://buy.itunes.apple.com/verifyReceipt", body) do
      {:ok, response} -> to_receipt(response.body)
      {:error, error} -> {:error, error.reason}
    end
  end

  defp do_post(url, body) do
    Client.post(url, body, [{"content-type", "application/json"}])
  end

  defp to_receipt(body) do
    case body["status"] do
      21000 -> {:error, "The App Store could not read the JSON object you provided."}
      21002 -> {:error, "The data in the receipt-data property was malformed or missing."}
      21003 -> {:error, "The receipt could not be authenticated."}
      21005 -> {:error, "The receipt server is not currently available."}
      21007 -> {:error, "This receipt is from the test environment, but it was sent to the production environment for verification. Send it to the test environment instead."}
      21008 -> {:error, "This receipt is from the production environment, but it was sent to the test environment for verification. Send it to the production environment instead."}
      _valid -> {:ok, %Receipt{
                        quantity: body["receipt"]["quantity"],
                        product_id: body["receipt"]["product_id"],
                        transaction_id: body["receipt"]["transaction_id"],
                        original_transaction_id: body["receipt"]["original_transaction_id"],
                        purchase_date: body["receipt"]["purchase_date"],
                        original_purchase_date: body["receipt"]["original_purchase_date"],
                        expires_date: body["receipt"]["expires_date"],
                        cancellation_date: body["receipt"]["cancellation_date"],
                        app_item_id: body["receipt"]["app_item_id"],
                        version_external_identifier: body["receipt"]["version_external_identifier"],
                        web_order_line_item_id: body["receipt"]["web_order_line_item_id"]
                      }}
    end
  end
end
