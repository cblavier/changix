defmodule Changix.Entry do
  @moduledoc """
    Struct for a single changelog entry (ie. a single changelog file).
  """
  defstruct [
    :date,
    :kind,
    :title,
    :content
  ]

  def required_headers, do: ~w(date kind title)a
end
