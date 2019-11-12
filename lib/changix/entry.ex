defmodule Changix.Entry do
  @moduledoc """
    Struct for a single changelog entry (ie. a single changelog file).
  """
  defstruct [
    :date,
    :kind,
    :kind_label,
    :title,
    :content
  ]

  @doc """
    Returns a list of required header fields.
  """
  def required_headers, do: ~w(date kind)a
end
