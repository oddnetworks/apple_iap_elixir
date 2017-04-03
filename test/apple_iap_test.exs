defmodule AppleIAPTest do
  use ExUnit.Case, async: true
  
  import :meck
  alias AppleIAP

  setup do
    new :hackney
    on_exit fn -> unload() end
    :ok
  end

  test "verify_receipt/2" do
    receipt = %AppleIAP.Receipt{
      quantity: 1,
      product_id: "com.oddnetworks",
      transaction_id: "t_1",
      original_transaction_id: "ot_1",
      purchase_date: "2012-07-22T14:59:50",
      original_purchase_date: "2012-07-22T14:59:50",
      expires_date: "2012-07-22T14:59:50",
      cancellation_date: "2012-07-22T14:59:50",
      app_item_id: "a_1",
      version_external_identifier: "e_1",
      web_order_line_item_id: "w_o_1"
    }

    request = %{
      "receipt-data" => "BA5E64",
      "password" => "pass1"
    }

    response = %{
      "status" => 0,
      "receipt" => %{
        "quantity" => 1,
        "product_id" => "com.oddnetworks",
        "transaction_id" => "t_1",
        "original_transaction_id" => "ot_1",
        "purchase_date" => "2012-07-22T14:59:50",
        "original_purchase_date" => "2012-07-22T14:59:50",
        "expires_date" => "2012-07-22T14:59:50",
        "cancellation_date" => "2012-07-22T14:59:50",
        "app_item_id" => "a_1",
        "version_external_identifier" => "e_1",
        "web_order_line_item_id" => "w_o_1"
      }
    }

    expect(
      :hackney, 
      :request, 
      [
        {
          [:post, "https://buy.itunes.apple.com/verifyReceipt", [{"accept", "application/json"}, {"content-type", "application/json"}], Poison.encode!(request), []],
          {:ok, 200, [], :client}
        }
      ])
    expect(:hackney, :body, 1, {:ok, Poison.encode!(response)})

    assert {:ok, receipt} == AppleIAP.verify_receipt("pass1", "BA5E64")

    assert validate :hackney
  end

  test "verify_receipt/3" do
    receipt = %AppleIAP.Receipt{
      quantity: 1,
      product_id: "com.oddnetworks",
      transaction_id: "t_1",
      original_transaction_id: "ot_1",
      purchase_date: "2012-07-22T14:59:50",
      original_purchase_date: "2012-07-22T14:59:50",
      expires_date: "2012-07-22T14:59:50",
      cancellation_date: "2012-07-22T14:59:50",
      app_item_id: "a_1",
      version_external_identifier: "e_1",
      web_order_line_item_id: "w_o_1"
    }

    request = %{
      "receipt-data" => "BA5E64",
      "password" => "pass1"
    }

    response = %{
      "status" => "t_2",
      "receipt" => %{
        "quantity" => 1,
        "product_id" => "com.oddnetworks",
        "transaction_id" => "t_1",
        "original_transaction_id" => "ot_1",
        "purchase_date" => "2012-07-22T14:59:50",
        "original_purchase_date" => "2012-07-22T14:59:50",
        "expires_date" => "2012-07-22T14:59:50",
        "cancellation_date" => "2012-07-22T14:59:50",
        "app_item_id" => "a_1",
        "version_external_identifier" => "e_1",
        "web_order_line_item_id" => "w_o_1"
      }
    }

    expect(
      :hackney, 
      :request, 
      [
        {
          [:post, "https://sandbox.itunes.apple.com/verifyReceipt", [{"accept", "application/json"}, {"content-type", "application/json"}], Poison.encode!(request), []],
          {:ok, 200, [], :client}
        }
      ])
    expect(:hackney, :body, 1, {:ok, Poison.encode!(response)})

    assert {:ok, receipt} == AppleIAP.verify_receipt(:sandbox, "pass1", "BA5E64")

    assert validate :hackney
  end

  test "error is returned from apple" do
    request = %{
      "receipt-data" => "BA5E64",
      "password" => "pass1"
    }

    response = %{
      "status" => 21003,
      "receipt" => %{}
    }

    expect(
      :hackney, 
      :request, 
      [
        {
          [:post, "https://buy.itunes.apple.com/verifyReceipt", [{"accept", "application/json"}, {"content-type", "application/json"}], Poison.encode!(request), []],
          {:ok, 200, [], :client}
        }
      ])
    expect(:hackney, :body, 1, {:ok, Poison.encode!(response)})

    assert {:error, "The receipt could not be authenticated."} == AppleIAP.verify_receipt("pass1", "BA5E64")

    assert validate :hackney
  end
end
