# speak_ex
An Elixir framework for building telephony applications

## Configuration

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
        {:username, "username"},
        {:secret, "secret"}
      ]} ]
  ```

More documentation is coming soon. 

For a brief tutorial, please visit [Elixir Survey Tutorial](https://github.com/smpallen99/elixir_survey_tutorial)

## License

`speak_ex` is Copyright (c) 2015 E-MetroTel

The source code is released under the MIT License.

Check [LICENSE](LICENSE) for more information.
