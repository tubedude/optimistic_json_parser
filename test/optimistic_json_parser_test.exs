defmodule OptimisticJsonParserTest do
  use ExUnit.Case
  doctest OptimisticJsonParser

  test "parses complete valid JSON" do
    json = ~s({"name": "John", "age": 30})
    assert {:ok, %{"name" => "John", "age" => 30}} = OptimisticJsonParser.parse(json)
  end

  test "returns error for very incomplete JSON" do
    json = ~s({"name":)
    assert {:error, :invalid_json} = OptimisticJsonParser.parse(json)
  end

  test "parses incomplete JSON with partial string" do
    json = ~s({"name": "Jo)
    assert {:ok, %{"name" => "Jo"}} = OptimisticJsonParser.parse(json)
  end

  test "returns error for incomplete JSON with partial key" do
    json = ~s({"name": "John", "age)
    assert {:error, :invalid_json} = OptimisticJsonParser.parse(json)
  end

  test "parses JSON with unclosed brackets" do
    json = ~s({"items": [1, 2, 3)
    assert {:ok, %{"items" => [1, 2, 3]}} = OptimisticJsonParser.parse(json)
  end

  test "parses JSON with multiple unclosed structures" do
    json = ~s({"users": [{"name": "John", "age": 30}, {"name": "Jane")

    assert {:ok, %{"users" => [%{"name" => "John", "age" => 30}, %{"name" => "Jane"}]}} =
             OptimisticJsonParser.parse(json)
  end
end
