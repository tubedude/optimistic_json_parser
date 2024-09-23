defmodule OptimisticJsonParser do
  @moduledoc """
  OptimisticJsonParser provides functionality to parse potentially incomplete JSON strings.

  This module is particularly useful when working with streaming JSON data, where you might
  receive partial JSON structures and want to parse them as soon as possible.

  The parser attempts to balance any unclosed structures (objects, arrays, or strings) before
  parsing, allowing it to handle incomplete JSON in many cases. However, it will return an
  error for JSON that is too incomplete to form a valid structure.
  """

  @doc """
  Parses a potentially incomplete JSON string.

  This function attempts to balance any unclosed structures in the input JSON string
  before parsing it. If the resulting balanced JSON is valid, it returns the parsed
  structure. If the JSON is invalid or cannot be balanced into a valid structure,
  it returns an error.

  ## Parameters

    - partial_json: A binary string containing the JSON to parse.

  ## Returns

    - `{:ok, parsed_json}` if the JSON could be parsed successfully.
    - `{:error, :invalid_json}` if the JSON is invalid or couldn't be parsed.

  ## Examples

      iex> OptimisticJsonParser.parse(~s({"name":))
      {:error, :invalid_json}

      iex> OptimisticJsonParser.parse(~s({"name": "Jo))
      {:ok, %{"name" => "Jo"}}

      iex> OptimisticJsonParser.parse(~s({"name": "John", "age))
      {:error, :invalid_json}

      iex> OptimisticJsonParser.parse(~s({"name": "John", "age": 30}))
      {:ok, %{"name" => "John", "age" => 30}}

  """
  @spec parse(binary()) :: {:ok, map()} | {:error, :invalid_json}
  def parse(partial_json) when is_binary(partial_json) do
    case balance_json(partial_json) do
      {:complete, balanced_json} ->
        decode_json(balanced_json)

      {:incomplete, balanced_json} ->
        decode_json(balanced_json)
    end
  end

  @spec decode_json(binary()) :: {:ok, map()} | {:error, :invalid_json}
  defp decode_json(json) do
    case Jason.decode(json) do
      {:ok, result} -> {:ok, result}
      {:error, _} -> {:error, :invalid_json}
    end
  end

  @spec balance_json(binary()) :: {:complete | :incomplete, binary()}
  defp balance_json(json) do
    {status, balanced, _stack} = balance_json_rec(json, [], [])
    {status, IO.iodata_to_binary(Enum.reverse(balanced))}
  end

  @spec balance_json_rec(binary(), list(), list()) :: {:complete | :incomplete, list(), list()}
  defp balance_json_rec(<<>>, acc, []) do
    {:complete, acc, []}
  end

  defp balance_json_rec(<<>>, acc, stack) do
    balanced = close_unclosed(acc, stack)
    {:incomplete, balanced, []}
  end

  defp balance_json_rec(<<char, rest::binary>>, acc, stack) do
    case {char, stack} do
      {?{, _} -> balance_json_rec(rest, [char | acc], [?} | stack])
      {?[, _} -> balance_json_rec(rest, [char | acc], [?] | stack])
      {?", [?" | rest_stack]} -> balance_json_rec(rest, [char | acc], rest_stack)
      {?", _} -> balance_json_rec(rest, [char | acc], [?" | stack])
      {?}, [?} | rest_stack]} -> balance_json_rec(rest, [char | acc], rest_stack)
      {?], [?] | rest_stack]} -> balance_json_rec(rest, [char | acc], rest_stack)
      {_, _} -> balance_json_rec(rest, [char | acc], stack)
    end
  end

  @spec close_unclosed(list(), list()) :: list()
  defp close_unclosed(acc, stack) do
    Enum.reduce(stack, acc, fn
      ?}, acc -> [?} | acc]
      ?], acc -> [?] | acc]
      ?", acc -> [?" | acc]
      _, acc -> acc
    end)
  end
end
