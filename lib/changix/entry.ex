defmodule Changix.Entry do
  @moduledoc """
    Struct for a single changelog entry (ie. a single changelog file).
  """
  defstruct [
    :datetime,
    :path,
    :kind,
    :kind_label,
    :title,
    :content,
    :summary_html,
    :full_html
  ]

  @doc """
    Returns a list of required header fields.
  """
  def required_headers, do: ~w(datetime kind path)a
end
