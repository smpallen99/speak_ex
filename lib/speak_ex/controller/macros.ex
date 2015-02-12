defmodule ExComm.CallController.Macros do
 # import ExComm.Utils

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
    end
  end 

  @doc """
  Creates API functions.

  Creates a def name(call) and a def name!(call) function:

  ## Example

    api :answer

    Creates the following two functions:

    def answer(call opts \\ []), do: command(:answer, [call] ++ opts)
    def answer!(call, opts \\ []) do
      answer(call, opts)
      call
    end

  """
  defmacro api(name), do: _api(name, name)
  defmacro api(name, command_name), do: _api(name, command_name)

  defp _api(name, command_name) do
    fun2 = String.to_atom("#{name}!")
    quote do
      def unquote(name)(call, opts \\ []), do: command(unquote(name), [call] ++ opts)
      def unquote(fun2)(call, opts \\ []) do
        unquote(name)(call, opts)
        call
      end
    end
  end


end
