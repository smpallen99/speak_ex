defmodule SpeakEx.RouterTest.Router do
  use SpeakEx.Router

  router do 
    route "From 555", SpeakEx.RouterTest.Router2, from: "555"
    route "To 1235", SpeakEx.RouterTest.Router3, to: "1235"
    route "Default Route", SpeakEx.RouterTest
  end
end

defmodule SpeakEx.RouterTest.Router2 do
  def run(call) do
    {:router2, call}
  end
end
defmodule SpeakEx.RouterTest.Router3 do
  def run(call) do
    {:router3, call}
  end
end

defmodule SpeakEx.RouterTest do
  use ExUnit.Case

  def run(call) do
    call
  end

  def test_call, do: {:agicall, 
    [
      {'agi_network', 'yes'}, 
      {'agi_request', 'agi://10.30.15.240:20000'}, {'agi_channel', 'SIP/200-00000008'}, 
      {'agi_language', 'en'}, {'agi_type', 'SIP'}, {'agi_uniqueid', '1442881616.8'}, 
      {'agi_version', '11.18.0'}, {'agi_callerid', '200'}, {'agi_calleridname', '200'}, 
      {'agi_callingpres', '0'}, {'agi_callingani2', '0'}, {'agi_callington', '0'}, 
      {'agi_callingtns', '0'}, {'agi_dnid', '5555'}, {'agi_rdnis', 'unknown'}, 
      {'agi_context', 'from-internal'}, {'agi_extension', '5555'}, {'agi_priority', '2'}, 
      {'agi_enhanced', '0.0'}, {'agi_accountcode', []}, {'agi_threadid', '140121545627392'}
    ], 
    :func1, :fun2, :fun3}

  def test_call_2, do: {:agicall, [{'agi_extension', '1234'}, {'agi_callerid', '555'}]}
  def test_call_3, do: {:agicall, [{'agi_extension', '1235'}, {'agi_callerid', '444'}]}

  test "gets extension with list" do
    assert SpeakEx.Utils.get_channel_variable(test_call(), 'extension') == "5555"
  end
  test "gets channel with string" do
    assert SpeakEx.Utils.get_channel_variable(test_call(), "channel") == "SIP/200-00000008"
  end
  test "gets callerid with atom" do
    assert SpeakEx.Utils.get_channel_variable(test_call(), :callerid) == "200"
  end

  test "it finds a default route" do
    call = test_call()
    assert SpeakEx.RouterTest.Router.do_router(call) == {:ok, call}
  end

  test "it finds route with from" do
    call = test_call_2() 
    assert SpeakEx.RouterTest.Router.do_router(call) == {:ok, {:router2, call}}
  end
  test "it finds route with to" do
    call = test_call_3()
    assert SpeakEx.RouterTest.Router.do_router(call) == {:ok, {:router3, call}}
  end

end
