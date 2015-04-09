defmodule SpeakEx do
  alias ExAmi.Message
  def is_error_message?(message) do
    Message.is_response(message) and Message.is_response_error(message)
  end
end
