# Changix

Very small & simple Elixir library that gives you changelog features based on markdown files.
It leverages on Elixir _metaprogramming_ features, so that everything is done at compile time.

Changix come with no runtime dependency, and can be used with any _Markdown_ parser. 
A default behavior is implemented if earmark(https://github.com/pragdave/earmark) markdown library is present.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `changix` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:changix, "~> 0.1.0"}
  ]
end
```

## Usage

```elixir
defmodule MyModule do

  include Changix, path: "my_changelog_folder"
  
  def list_entries do
    for entry <- MyModule.changelog_entries() do
      IO.inspect(entry)
    end
  end

  def show_entry(entry_date) do
    date
    |> MyModule.changelog_entry()
    |> IO.inspect
  end

end
```

## Documentation

Docs can be found at [https://hexdocs.pm/changix](https://hexdocs.pm/changix).

