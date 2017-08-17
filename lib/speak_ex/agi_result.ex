defmodule SpeakEx.AgiResult do
  defstruct result: false, timeout: false, digits: false, offset: false,
    data: false, cmd: false, raw: false

  def new({:agiresult, result, timeout, digits, offset, data, cmd, raw}) do
    %__MODULE__{result: result, timeout: timeout, digits: digits,
      offset: offset, data: data, cmd: cmd, raw: raw}
  end

  def new(other) do
    other
  end
end
