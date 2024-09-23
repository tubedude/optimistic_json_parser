# OptimisticJsonParser

OptimisticJsonParser is an Elixir library designed to parse potentially incomplete JSON strings. It's particularly useful when working with streaming JSON data, where you might receive partial JSON structures and want to parse them as soon as possible.

## Features

- Parses complete and incomplete JSON strings
- Attempts to balance unclosed structures (objects, arrays, or strings) before parsing

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed by adding `optimistic_json_parser` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:optimistic_json_parser, "~> 0.1.0"}
  ]
end
```

## Usage

Here are some examples of how to use OptimisticJsonParser:

```elixir
iex> OptimisticJsonParser.parse(~s({"name":))
{:error, :invalid_json}

iex> OptimisticJsonParser.parse(~s({"name": "Jo))
{:ok, %{"name" => "Jo"}}

iex> OptimisticJsonParser.parse(~s({"name": "John", "age))
{:error, :invalid_json}

iex> OptimisticJsonParser.parse(~s({"name": "John", "age": 30}))
{:ok, %{"name" => "John", "age" => 30}}
```

## Documentation

Detailed documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc) and published on [HexDocs](https://hexdocs.pm). Once published, the docs can be found at <https://hexdocs.pm/optimistic_json_parser>.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the [MIT License](LICENSE).