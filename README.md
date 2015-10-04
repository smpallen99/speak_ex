# speak_ex
An Elixir framework for building telephony applications, inspired heavily by Ruby's [Adhearsion](http://adhearsion.com/).

SpeakEx enables easy integration of Elixir and Phoenix voice applications with [Asterisk](http://www.asterisk.org/). For example, build a simple voice survey application with [Elixir Survey Tutorial](https://github.com/smpallen99/elixir_survey_tutorial) or a call out system.

## Getting Started

### Configure Asterisk

Configure some extensions to be routed to the SpeakEx application.

/etc/asterisk/extensions_custom.conf
```
[from-internal-custom]
include => speak-ex

[speak-ex]
exten => _5XXX,1,Noop(SpeakEx Demo)
exten => _5XXX,n,AGI(agi://10.1.2.209:20000)
```

Configure an account for AMI. 

/etc/asterisk/manager.conf
```
[elixirconf]
secret = elixirconf
deny=0.0.0.0/0.0.0.0
permit=127.0.0.1/255.255.255.0
read = system,call,log,verbose,command,agent,user,config,command,dtmf,reporting,cdr,dialplan,originate
write = system,call,log,verbose,command,agent,user,config,command,dtmf,reporting,cdr,dialplan,originate
writetimeout = 5000
```

Reload asterisk with `asterisk -rx reload`

### Setup your Elixir project

#### Install the dependency

mix.exs
```elixir
      ...
      {:speak_ex, github: "smpallen99/speak_ex"},
      ...
```

Fetch and compile the dependency:

```
mix do deps.get, compile 
```

#### Configure AGI and AMI in your elixir project

SpeakEx uses both ExAmi and erlagi. Configuration is needed for both as follows:

config/config.exs
```elixir
  config :erlagi,
    listen: [
      {:localhost, host: '127.0.0.1', port: 20000, backlog: 5, 
          callback: SpeakEx.CallController}
    ]

  config :ex_ami, 
    servers: [
      {:asterisk, [
        {:connection, {ExAmi.TcpConnection, [
          {:host, "127.0.0.1"}, {:port, 5038}
        ]}},
        {:username, "elixirconf"},
        {:secret, "elixirconf"}
      ]} ]
  ```

#### Configure swift for text-to-speech

If you want to use text to speech and have [Cepstral](http://www.cepstral.com/) installed on Asterisk, add the following:

config/config.exs
```elixir
config :speak_ex, :renderer, :swift
```

#### Create a voice route

Create a call router to route all incoming calls to the CallController.

lib/call_router.ex
```elixir
defmodule Survey.CallRouter do
  use SpeakEx.Router

  router do 
    route "Survey", MyProject.CallController # , to: ~r/5555/
  end
end
```

#### Create a call controller to handle your call

A sample call controller to answer the call say welcome and hang up.

lib/call_controller.ex
```elixir
defmodule MyProject.CallController do
  use SpeakEx.CallController

  def run(call) do
    call
    |> answer!
    |> say(welcome)
    |> hangup!
    |> terminate!
  end
end
```

More documentation is coming soon. 

## License

`speak_ex` is Copyright (c) 2015 E-MetroTel

The source code is released under the MIT License.

Check [LICENSE](LICENSE) for more information.
