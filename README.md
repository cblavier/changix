# Changix

![](https://github.com/actions/cblavier/changix/CI/badge.svg)

Small & simple Elixir library that gives you changelog features based on markdown files.
It leverages on Elixir _metaprogramming_ features, so that everything is done at compile time, with following benefits:

- **fast**: no filesystem access or Markdown parsing at runtime. HTML is directly embedded in your compiled code.
- **reliable**: any error in your changelog files will be reported at compile time

Changix does not provide any UI widget, but you will be in good direction to write one into your Phoenix app. A demo webapp with source_code will be released very soon!

Changix come with no runtime dependency, and can be used with any _Markdown_ parser. 
A default behavior is implemented if [earmark](https://github.com/pragdave/earmark) markdown library is present.

## Installation

Add `changix` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:changix, "~> 0.1.0"}
  ]
end
```

If you don't use any Markdown library, I recommand you also add [earmark](https://github.com/pragdave/earmark) to your dependencies.


## Usage

Create a `changelog` folder at the root of your project and write separate changelog files after each of your release.

A changelog file must contain a _YAML Front Matter_ header with `datetime` and `kind` attributes. `title` is optional. 

A mix task to generate new changelog entries will be shipped to `changix` very quickly.

```yaml
datetime: 2019-11-10T17:10:05
kind: bugfix
title: Fixed Lorem
---
# Your change summary in whatever Markdown you want
Lorem _ipsum dolor_ sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

<!--more-->

# Further details in the read-more section
Lorem _ipsum dolor_ sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
```

Then simply including `Changix` will give you access to all your changelog entries.

```elixir
defmodule MyModule do

  include Changix
  
  def list_entries do
    for entry <- changelog_entries() do
      IO.inspect(entry)
    end
  end

  def show_entry(entry_datetime) do
    entry_datetime
    |> changelog_entry()
    |> IO.inspect
  end

end
```

## Documentation

Docs can be found at [https://hexdocs.pm/changix](https://hexdocs.pm/changix).

