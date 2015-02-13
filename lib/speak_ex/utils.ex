defmodule SpeakEx.Utils do

  def any_to_char_list(string) when is_binary(string), do: String.to_char_list(string)
  def any_to_char_list(list) when is_list(list), do: list
  def any_to_char_list(int) when is_integer(int), do: Integer.to_char_list(int)
  
end
