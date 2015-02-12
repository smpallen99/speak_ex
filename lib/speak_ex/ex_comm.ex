defmodule ExComm do
  require Logger
  import ExComm.Utils

  @redirect_number  "1"

  def originate(to, options \\ []) do
    event_handler = Keyword.get(options, :event_handler, nil)
    context = get_setting(options, :context, "from-internal")
    priority = get_setting(options, :priority, "1")
    exten = get_setting(options, :exten, @redirect_number)
    caller_pid_var = Keyword.get(options, :caller_pid, self) |> get_caller_pid_var

    ExAmi.Client.Originate.dial(:asterisk, to, {context, exten, priority}, 
      [caller_pid_var], &__MODULE__.response_callback/2)
  end

  defp get_caller_pid_var(pid) do
    {"caller_pid", (inspect(pid) |> String.replace("#PID", ""))}
  end

  #def response_callback(response, events, nil) do
  def response_callback(response, events) do
    Logger.info "***********************************************"
    Logger.info ExAmi.Message.format_log(response)
    for event <-  events, do: Logger.info(ExAmi.Message.format_log(event))
    Logger.info "***********************************************"
  end
  def response_callback(response, events, handler) do
    handler.(response, events)
  end

  def get_setting(options, key, default) do
    Keyword.get(options, key, default)
  end

end
