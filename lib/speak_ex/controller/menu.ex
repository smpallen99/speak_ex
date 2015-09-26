defmodule SpeakEx.CallController.Menu do
  import SpeakEx.Utils
  alias SpeakEx.AgiResult
  require Logger
  import SpeakEx.CallController
  import SpeakEx.Output
  alias SpeakEx.CallController.Menu

  defmacro __using__(_options) do
    quote do
      alias SpeakEx.CallController.Menu
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
      Menu.__menu(unquote(call), unquote(prompt), unquote(options), commands, 1)
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

      press = 
      case render(call, prompt, num_digits: 1, digits: '#*1234567890', timeout: timeout) do
        %AgiResult{timeout: true} = res -> 
          # The user has let the prompt play to completion
          case run_command(:erlagi, :wait_digit, [call, timeout]) do
            %AgiResult{timeout: false, data: data} -> data
            %AgiResult{timeout: true} -> :timeout
          end
        %AgiResult{data: data} = res -> 
          # The user has interrupted the playback
          data
      end

      if press == :timeout do
        timeout = commands[:timeout]
        if timeout, do: timeout.()
        unless Menu.__check_and_handle_failure(call, tries, count, commands), 
          do: Menu.__menu(call, prompt, options, commands, count + 1)
      else
        case Enum.find commands[:matches], &(__press_valid?(&1, press)) do
          nil -> 
            invalid = commands[:invalid]
            if invalid, do: invalid.(press)
            unless Menu.__check_and_handle_failure(call, tries, count, commands), do: 
              Menu.__menu(call, prompt, options, commands, count + 1)
          {_value, fun} -> 
            cond do
              is_function(fun, 0) -> fun.()
              is_function(fun, 1) -> fun.(press)
              true -> :ok
            end
        end
      end
    rescue 
      all -> 
        failure = commands[:failure]
        if failure, do: failure.()
    end
  end
  def __press_valid?(match, press) when is_binary(press) do
    __press_valid?(match, String.to_integer(press) + ?0)
  end
  def __press_valid?(match, [press | _]) do
    __press_valid? match, press
  end
  def __press_valid?(match, press) do
    press in elem(match, 0)
  end

end
