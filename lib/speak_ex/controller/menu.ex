defmodule SpeakEx.CallController.Menu do

  @moduledoc """
  Defines a voice menu.

  A menu provides a way to play voice prompts to a user and DTMF input
  from the user. For example:

      menu "Press 1 for yes, or 2 for no", timeout: 3000, tries: 3 do
        match '1', fn -> say "You answered yes" end
        match '2', fn -> say "You answered no" end
        invalid fn(press) -> say "is invalid" end
        timeout fn -> say "times up, try again" end
      end
  
  """
  import SpeakEx.Utils
  alias SpeakEx.AgiResult
  require Logger
  import SpeakEx.CallController
  import SpeakEx.Output
  alias SpeakEx.CallController.Menu
  
  defmacro __using__(_options) do
    quote do
      alias SpeakEx.CallController.Menu
      import unquote(__MODULE__), only: [menu: 4, match: 2, timeout: 1, 
        default: 1, invalid: 1, failure: 1] 
    end
  end 

  defmacro menu(call, prompt, options \\ [], do: block) do
    quote do
      var!(__timeout) = nil
      var!(__failure) = nil
      var!(__invalid) = nil
      var!(__matches) = []
      unquote(block)
      commands = %{matches: var!(__matches), invalid: var!(__invalid), timeout: var!(__timeout), failure: var!(__failure)}
      Menu.do_menu(unquote(call), unquote(prompt), unquote(options), commands, 1)
    end
  end
  
  defmacro match(value, fun) do
    quote do
      var!(__matches) = var!(__matches) ++ [{unquote(value), unquote(fun)}]
    end
  end

  defmacro timeout(fun) do
    quote do
      var!(__timeout) = unquote(fun)
    end
  end

  defmacro default(fun) do
    quote do
      var!(__invalid) = unquote(fun)
    end
  end

  defmacro invalid(fun) do
    quote do
      var!(__invalid) = unquote(fun)
    end
  end

  defmacro failure(fun) do
    quote do
      var!(__failure) = unquote(fun)
    end
  end

  @doc false
  def do_menu(call, prompt, options, commands, count) do
    tries  = Keyword.get(options, :tries, 0) 
    try do
      timeout = Keyword.get(options, :timeout, '-1')
      |> any_to_char_list

      get_response(call, prompt, timeout)
      |> handle_timeout(call, prompt, options, commands, count, tries) 
      |> handle_matches(call, prompt, options, commands, count, tries) 
    rescue 
      all -> 
        Logger.error "Exception: #{inspect all}"
        commands[:failure]
        |> handle_callback(:failure, :ok)
        |> handle_call_back_response(call, prompt, options, commands, count, tries)
    end
  end

  defp get_response(call, prompt, timeout) do
    case render(call, prompt, num_digits: 1, digits: '#*1234567890', timeout: timeout) do
      %AgiResult{timeout: true} -> 
        # The user has let the prompt play to completion
        case run_command(:erlagi, :wait_digit, [call, timeout]) do
          %AgiResult{timeout: false, data: data} -> data
          %AgiResult{timeout: true} -> :timeout
        end
      %AgiResult{data: data} -> 
        # The user has interrupted the playback
        data
    end
  end

  defp handle_timeout(:timeout, call, prompt, options, commands, count, tries) do
    fun = commands[:timeout]
    if fun, do: fun.()
    unless check_and_handle_failure(call, tries, count, commands), 
      do: do_menu(call, prompt, options, commands, count + 1)
    :timeout
  end
  defp handle_timeout(press, _call, _prompt, _options, _commands, _count, _tries) do
    press
  end

  defp handle_matches(:timeout, _call, _prompt, _options, _commands, _count, _tries) do
    :timeout
  end
  defp handle_matches(press, call, prompt, options, commands, count, tries) do
    case Enum.find commands[:matches], &(press_valid?(&1, press)) do
      nil -> 
        commands[:invalid]
        |> handle_callback(press, :invalid) 
        |> handle_call_back_response(call, prompt, options, commands, count, tries)
      {_value, fun} -> 
        fun
        |> handle_callback(press, :ok)
        |> handle_call_back_response(call, prompt, options, commands, count, tries)
    end
  end

  defp check_and_handle_failure(_call, tries, count, commands) do
    if (tries != :infinite) and (count >= tries) do
      fun = commands[:failure]
      if fun, do: fun.()
      true
    end
  end

  defp handle_callback(fun, press, default) do
    cond do
      is_function(fun, 0) -> fun.()
      is_function(fun, 1) -> fun.(press)
      true -> default
    end
  end

  defp handle_call_back_response(resp, call, prompt, options, commands, count, tries) do
    case resp do
      :invalid -> 
        unless check_and_handle_failure(call, tries, count, commands) do 
          Menu.do_menu(call, prompt, options, commands, count + 1)
        else 
          :ok
        end
      :repeat -> 
        do_menu(call, prompt, options, commands, count)
      other -> 
        other
    end
  end

  defp press_valid?(match, <<press::8, _::binary>>) do
    press_valid?(match, press)
  end
  defp press_valid?(match, [press | _]) do
    press_valid? match, press
  end
  defp press_valid?(match, press) do
    press in elem(match, 0)
  end

end
