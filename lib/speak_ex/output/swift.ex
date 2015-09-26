defmodule SpeakEx.Output.Swift do
  
  @break_x_weak         " <break strength='x-weak' /> "
  @break_weak           " <break strength='weak' /> "
  @break_medium         " <break strength='medium' /> "
  @break_strong         " <break strength='strong' /> "
  @break_x_strong       " <break strength='x-strong' /> "

  @rate_x_slow          " <prosody rate='x-slow'> "
  @rate_slow            " <prosody rate='slow'> "
  @rate_medium          " <prosody rate='medium'> "
  @rate_fast            " <prosody rate='fast'> "
  @rate_x_fast          " <prosody rate='x-fast'> "
  @rate_default         " <prosody rate='default'> "

  def swift, do: [
    break: [
      x_weak:           @break_x_weak,
      weak:             @break_weak,
      medium:           @break_medium,
      strong:           @break_strong,
      x_strong:         @break_x_strong,

      phrase:           @break_x_weak,
      phrase_strong:    @break_weak,
      sentence:         @break_medium,
      paragraph:        @break_strong,
      paragraph_strong: @break_x_strong,
      sec:              fn(sec) -> " <break time='#{sec}s' /> " end,
      ms:               fn(ms) ->  " <break time='#{ms}ms' /> " end,
    ],
    speech_rate: [
      x_slow:           @rate_x_slow,
      slow:             @rate_slow,
      medium:           @rate_medium,
      fast:             @rate_fast,
      x_fast:           @rate_x_fast,
      default:          @rate_default,
      value:            fn(v) ->  " <prosody rate='#{v}'> " end,

      half:             @rate_x_slow,
      two_thirds:       @rate_slow,
      normal:           @rate_default,
      third_faster:     @rate_fast,
      twice_faster:     @rate_x_fast,
    ]
  ]
end
