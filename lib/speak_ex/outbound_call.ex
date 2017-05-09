defmodule SpeakEx.OutboundCall do
  require Logger

  @redirect_number  "1"

  def originate(channel, extension, context, priority, variables \\ [], callback \\ nil) do
    ExAmi.Client.Originate.dial(:asterisk, channel, {context, extension, priority}, variables, callback, []) 
  end
  
  def originate(to, options \\ []) do
    # event_handler = Keyword.get(options, :event_handler, nil)
    context = get_setting(options, :context, "from-internal")
    priority = get_setting(options, :priority, "1")
    exten = get_setting(options, :exten, @redirect_number)
    callback = get_setting(options, :callback, nil)
    caller_pid_var = Keyword.get(options, :caller_pid, self()) |> get_caller_pid_var

    opts = Keyword.drop options, [:event_handler, :context, :priority, :exten, :callback, :caller_pid]

    ExAmi.Client.Originate.dial(:asterisk, to, {context, exten, priority}, 
      [caller_pid_var], callback, opts)
  end

  defp get_caller_pid_var(pid) do
    {"caller_pid", (inspect(pid) |> String.replace("#PID", ""))}
  end

  def get_setting(options, key, default) do
    Keyword.get(options, key, default)
  end
end
