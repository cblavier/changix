defmodule Changix do
  @moduledoc ~S"""
    Compile-time changelog features from static changelog files.
  """

  defmacro __using__(_opts \\ []) do
    quote do
      def hello do
        :world
      end
    end
  end
end
