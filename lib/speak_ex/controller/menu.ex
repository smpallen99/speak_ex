defmodule SpeakEx.CallController.Menu do
  import SpeakEx.Utils
  alias SpeakEx.AgiResult
  require Logger
  import SpeakEx.CallController

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
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
      SpeakEx.CallController.Menu.__menu(unquote(call), unquote(prompt), unquote(options), commands, 1)
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

  def __check_and_handle_failure(call, tries, count, commands) do
    if (tries != :infinite) and (count >= tries) do
      failure = commands[:failure]
      if failure, do: failure.()
      true
    end
  end

  def __menu(call, prompt, options, commands, count) do
    try do
      tries  = Keyword.get(options, :tries, 0) 
      timeout = Keyword.get(options, :timeout, '-1')
      |> any_to_char_list

      press = case stream_file(call, [prompt, '#*1234567890']) do
        %AgiResult{data: [0]} -> 
          # The user has let the prompt play to completion
          case run_command(:erlagi, :wait_digit, [call, timeout]) do
            %AgiResult{timeout: false, data: data} -> data
            %AgiResult{timeout: true} -> :timeout
          end
        %AgiResult{data: data} -> 
          # The user has interrupted the playback
          data
      end

      Logger.debug "__menu - press: #{press}"

      if press == :timeout do
        timeout = commands[:timeout]
        if timeout, do: timeout.()
        unless SpeakEx.CallController.Menu.__check_and_handle_failure(call, tries, count, commands), do: 
          SpeakEx.CallController.Menu.__menu(call, prompt, options, commands, count + 1)
      else
        case Enum.find commands[:matches], &(elem(&1,0) == press) do
          nil -> 
            invalid = commands[:invalid]
            if invalid, do: invalid.(press)
            unless SpeakEx.CallController.Menu.__check_and_handle_failure(call, tries, count, commands), do: 
              SpeakEx.CallController.Menu.__menu(call, prompt, options, commands, count + 1)
          {_value, fun} -> 
            if fun, do: fun.()
            :ok
        end
      end
    rescue 
      all -> 
        Logger.debug "Exception: #{inspect all}"
        failure = commands[:failure]
        if failure, do: failure.()
    end
  end
end
