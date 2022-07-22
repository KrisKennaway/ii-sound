# ][-Sound

High quality audio player for streaming audio over Ethernet, for the Apple II.

Requires:
*  Uthernet II (currently assumed to be in slot 3)
*  Enhanced //e or (untested) //gs.  
    * The player should run on 6502 but about 10% _faster_ on a 6502 than 65c02 (and with lower audio quality, until
    the encoder understands this).  See "future work" below.

NOTE: Ethernet addresses are hardcoded to 10.0.0.1 for the server and 10.0.65.02 for the Apple II.  This is not
currently configurable without reassembling.

The audio encoder runs on a modern machine, and produces an encoded audio file suitable for playback on the Apple
II, via ethernet streaming.

To encode audio, ][-Sound simulates the movement of the Apple II speaker clock cycle by cycle, and computes the exact
clock cycles at which to invert the applied speaker voltage, so that the speaker traces out the desired audio waveform as accurately
as possible.

The resulting audio file causes the Apple II to follow this speaker trajectory with cycle-level precision when it is
played, and typically ends up toggling the speaker about 100,000 times/second.

TODO: link KansasFest 2022 slides/video

## Usage

The simplest usage is:

```
$ ./encode_audio.py <input> <output.a2s>
```

where: 

*  `input` is the audio file to encode.  .mp3, .wav and probably others are supported.

*  `output.a2s` is the output file to write to.

TODO: document flags

## Playback

Download the (bootable) Apple II player disk image [here](player/player.dsk)

## Serving

This runs a HTTP server listening on port 1977 to which the player connects, then unidirectionally streams it the data.

```
$ ./play_audio.py <filename.a2s>
```

A sample audio file can be downloaded [here](examples/adventure.a2s.bz2) ("Adventure" by [Alexander Nakarada](http://www.serpentsoundstudios.com), licensed under [CC BY Attribution 4.0](https://creativecommons.org/licenses/by/4.0/)).  It first needs to be uncompressed, e.g.

```
% bunzip2 adventure.a2s.bz2
% ./play_audio adventure.a2s
```

# Details

## Theory of operation

Control of the Apple II speaker has very limited hardware support: accessing a special memory location ($C030 hex)
causes the voltage across the speaker to be inverted (toggled high/low), which causes the speaker cone to begin
switching position (in/out).  By itself, a single memory access causes the speaker to emit a 'click'.  Producing more
complex sounds from the Apple II requires accessing the speaker address repeatedly, under direct CPU control.

][-Sound uses a highly optimized audio player running on the Apple II that is capable of accessing the speaker
on _arbitrary_ clock cycles (i.e. at the maximum possible 1MHz resolution), as long as successive accesses are at least
10 cycles apart.

The audio encoder uses [delta modulation](https://en.wikipedia.org/wiki/Delta_modulation) to produce the audio output.
The audio stream is constructed based on a simulation of how the Apple II speaker behaves in response to changes in input
voltage, which is used to optimize the audio quality.

Delta modulation has been previously used for Apple II audio playback from memory, e.g. Oliver Schmidt's [PLAY.BTC](https://github.com/oliverschmidt/Play-BTc)
implements delta modulation at about 33KHz frequency and with 33Khz precision.  i.e. every ~30 cycles, it either toggles
the speaker or leaves it untouched for another 30 cycles.

The big difference with our approach is that we are able to achieve 1Mhz precision, and 100KHz frequency.  i.e. ][-Sound
is able to toggle the speaker at _any_ clock cycle (1MHz precision), as long as successive toggles are more than 10
cycles apart (100KHz frequency).

The other major improvement is in accuracy of the Apple II speaker simulation.   Previous delta modulation
implementations modeled the speaker as an [RC circuit](https://en.wikipedia.org/wiki/RC_circuit) (based on https://www.romanblack.com/picsound.htm
which described a number of variations of (Apple II-like) audio circuits and Delta modulation audio encoding algorithms,
which they referred to as "Binary Time Constant" audio).

Instead, ][-Sound models the speaker as an [RLC circuit](https://en.wikipedia.org/wiki/RLC_circuit), i.e. damped harmonic oscillator, which matches the actual
speaker response much more closely.  At very short timescales the response of an RLC circuit (oscillatory response to
applied voltage with exponential damping) looks approximately like that of an RC circuit (exponential response to
applied voltage), which is why the simpler approach still gives reasonable results.

## Player

The player consists of some ethernet setup code and a core playback loop of "player opcodes", which are the basic
operations that are dispatched to by the audio bytestream.

Some other tricks used here:

- The minimal 10-cycle (9-cycle) speaker loop is: `STA $C030; JMP (WDATA)`, where we use an undocumented property of the
  Uthernet II: the special I/O registers at $C0nx (which are used for communication with the onboard W5100 hardware)
  don't wire up all of the address lines, so they are also accessible at other address offsets.  In particular WDATA+1 is a duplicate copy of WMODE.  In our case WMODE happens to be 0x3.
  This lets us use WDATA as a dynamic jump table into page 3, where we place our player code.  We then choose the
  network byte stream to contain the low-order byte of the target address we want to jump to next, and we'll
  indirect-jump to $03xx.

- The core audio playback loop is a carefully chosen sequence of 6502 opcodes that can be chained together (via this
  `JMP (WDATA)` trick) to access the speaker at any interval of >=10 CPU cycles.  This only requires 16 bytes of space 
  which easily fits within page 3.
  
- By chaining together these "player opcodes", we can toggle the speaker at arbitrary clock cycles, but no more often
  than every 10 cycles.  This gives an upper bound of 102.4KHz for speaker accesses, which means a maximum audio
  frequency of 51.2KHz that is far outside audible range (this may seem like overkill, but a high modulation frequency is desirable in delta modulation to limit "quantization error", i.e. to allow zig-zagging back and forth as closely as possible around the target waveform) 

- As with my [\]\[-Vision](https://github.com/KrisKennaway/ii-vision) streaming video+audio player, we schedule a "slow
  path" dispatch to occur every 2KB in the byte stream, and use this to manage the socket buffers (ACK the read 2KB and
  wait until at least 2KB more is available, which is usually non-blocking).  While doing this we need to maintain a
  regular speaker cadence so the speaker is in a known trajectory.  We can also partly compensate for this in
  the audio encoder. 

## Encoding

The encoder models the Apple II speaker as an RLC circuit with parameters (resonance frequency and envelope decay rate)
fitted to the observed speaker response, and simulates the speaker response at 1MHz (i.e. cycle-level) time resolution.

At every step we evaluate the possible next choices for the player, i.e. which player "opcode" we should branch to
next, considering the effect this will have on the speaker movement.  For example, an opcode that will run for 10 cycles
and invert the speaker voltage on cycle 4. 

To optimize the audio quality we look ahead some defined number of cycles (e.g. 30 cycles gives good results) and choose
a speaker trajectory that minimizes errors over this range, considering all possible sequences of opcodes that we could
choose to schedule during this cycle window.  This makes the encoding exponentially slower, but improves quality since
it allows us to e.g. anticipate large amplitude changes by pre-moving the speaker to better approximate them.

This also needs to take into account scheduling the "slow path" every 2048 output bytes, where the Apple II will manage
the TCP socket buffer while ticking the speaker at some constant cadence of (a, b) cycles.  Since
we know this is happening we can compensate for it, i.e. look ahead to this upcoming slow path and pre-position the
speaker so that it introduces the least error during this period when we have to step away from direct cycle-level control of the speaker position.

# Future work

## Ethernet configuration

Hard-coding the ethernet config is not especially user friendly.  This should be configurable at runtime.

## In-memory playback

This level of audio quality requires high bit rate, about 92KB/sec.  So 1 minute of audio requires about 5.5MB of data.

A "Slinky" style memory card (RamFactor etc) uses a very similar I/O mechanism to the Uthernet II, i.e a $C0xx address
that auto-increments through the onboard memory space.  So it should be straightforward to extend ][-Sound to support
RamFactor playback.

Playback from bank-switched memory (e.g. RamWorks) should also be feasible, though would require a small amount of 
extra code to add the player opcode to switch banks.

The other option is to reduce bitrate (and therefore audio quality).  I think it should also be possible to improve
in-memory playback quality at similar bitrate, through using some of the cycle-level targeting techniques (though
probably not at full 1-cycle resolution).

## 6502 support

The player relies heavily on the JMP (indirect) 6502 opcode, which has a different cycle count on the 6502 (5 cycles)
and 65c02 (6 cycles).  This means the player will be about 10% **faster** on a 6502 (e.g. II+, Unenhanced //e), but
audio quality will be off until the encoder is made aware of this and able to compensate.

This might be one of the few pieces of software for which a 65c02 at the same clock speed causes a measurable
performance degradation (adding almost a minute to playback of an 8-minute song - hat tip to Scott Duensing who noticed
that my sample audio sounded "a tad slow", which turned out to be due to hearing this 1-cycle timing difference!
