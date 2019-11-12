defmodule Changix.Entries.Entry do
  @moduledoc """
    Struct for a single changelog entry (ie. a single changelog file).
  """
  defstruct [
    :datetime,
    :kind,
    :kind_label,
    :title,
    :content
  ]

  @doc """
    Returns a list of required header fields.
  """
  def required_headers, do: ~w(datetime kind)a
end
