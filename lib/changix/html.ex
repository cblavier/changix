defmodule Changix.HTML do
  @moduledoc """
    `Changix.HTML` provides a `render_content/2` function to tranform `Changix.Entry`
    content into HTML.
  """
  alias Changix.Entry

  @default_read_more_class "read-more"
  @default_read_more_label "Read more"

  @doc """
    Renders a `Changix.Entry` content into HTML.
    Takes following options :
    - summary: if true, only renders content above `<!--more-->` markup
    - read_more_class: css class given to the read_more link. Defaults to `read-more`
    - read_more_label: label of the read_more link. Defaults to `Read more`
    - render_function: function that takes a single markdown parameter and should return
      `{:ok, safe_html}` or `{:error, reason}`. Defaults to `Earmark`, if available.
  """
  def render_content(entry, opts \\ [summary: false])

  def render_content(%Entry{content: content, path: path}, opts = [summary: false]) do
    render_function = Keyword.get(opts, :render_function, &render_markdown/2)
    render_function.(content, path)
  end

  def render_content(%Entry{content: content, path: path}, opts = [summary: true]) do
    read_more_class = Keyword.get(opts, :read_more_class, @default_read_more_class)
    read_more_label = Keyword.get(opts, :read_more_label, @default_read_more_label)
    render_function = Keyword.get(opts, :render_function, &render_markdown/2)

    summary =
      case String.split(content, "<!--more-->", parts: 2) do
        [all_content] -> all_content
        [summary | _] -> summary <> "<div class='#{read_more_class}'>#{read_more_label} ...</div>"
      end

    render_function.(summary, path)
  end

  defp render_markdown(markdown, path) do
    case Code.ensure_loaded(Earmark) do
      {:module, mod} ->
        case mod.as_html(markdown) do
          {:ok, html, []} ->
            {:ok, html}

          {_, _html, errors} ->
            {:error, "Error while parsing Markdown in #{path}: #{inspect(errors)}"}

          _ ->
            {:error, "Unknown error while parsing Markdown in #{path}"}
        end

      _ ->
        {:error, "Earkmark not loaded"}
    end
  end
end
