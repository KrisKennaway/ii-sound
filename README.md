# ][-Sound

High quality audio player for streaming audio over Ethernet, for the Apple II.

**Dedicated to Woz on his 70th birthday.  Thank you for a lifetime of enjoyment exploring your wonderful creation.**

Requires:
*  Uthernet II (currently assumed to be in slot 1)
*  Enhanced //e or (untested) //gs.  
    * The player will run on 6502 (and should even run on a 16KB machine, although the disk image uses ProDOS) but about
    10% _faster_ on a 6502 than 65c02 (and with lower audio quality, until the encoder understands this).  See "future
    work" below.

NOTE: Ethernet addresses are hardcoded to 10.0.0.1 for the server and 10.0.65.02 for the Apple II.  This is not
currently configurable without reassembling.

## What this does

The audio encoder runs on your modern machine, and produces a bytestream suitable for playback on the Apple II, via
ethernet streaming.

It works by simulating the movement of the Apple II speaker at 1-cycle resolution, and computing the exact cycles
that the speaker cone should switch direction so that it traces out the desired audio waveform as accurately as
possible.  This includes looking some number of cycles into the future to anticipate upcoming changes in the waveform
(e.g. sudden spikes), so the speaker can be pre-positioned to best accommodate them.

The resulting bytestream directs the Apple II to follow this speaker trajectory with cycle-level precision, and
typically ends up toggling the speaker about 110000 times/second.

XXX new player size

The actual audio playback code is small enough (~150 bytes) to fit in page 3.  i.e. would have been small enough to type
in from a magazine back in the day.  The megabytes of audio data would have been hard to type in though ;)  Plus,
Uthernets didn't exist back then (although a Slinky RAM card would let you do something similar, see Future Work below).

# Implementation

The audio player uses [delta modulation](https://en.wikipedia.org/wiki/Delta_modulation) to produce the audio signal.
This signal is constructed based on an electrical model of how the Apple II behaves in response to input, which we
simulate to optimize the audio quality.

Delta modulation with an RC circuit is also called "BTC", after https://www.romanblack.com/picsound.htm who described
a number of variations on these (Apple II-like) audio circuits and Delta modulation audio encoding algorithms.  See e.g.
Oliver Schmidt's [PLAY.BTC](https://github.com/oliverschmidt/Play-BTc) for an Apple II implementation that plays from
memory at 33KHz.

The big difference with our approach is that we are able to target a 1MHz sampling rate, i.e. manipulate the speaker
with 1-cycle precision, by choosing how the "player opcodes" are chained together by the ethernet bytestream.
The catch is that once we have toggled the speaker we can't toggle it again until at least 10 cycles have passed (9
cycles on 6502), but we can pick any such interval >= 10 cycles (except for 11 cycles because of 65x02 opcode timing
limitations).  Successive choices are independent.

In other words, we are able to choose a precise sequence of clock cycles in which to toggle the speaker, but there is a
"cooldown" period and these cannot be spaced too close together.

The minimum period of 10 cycles is already short enough that it produces high-quality audio even if we only modulate
the speaker at a fixed cadence of 10 cycles (i.e. at 102.4KHz instead of 1MHz), although in practice a fixed 14-cycle
period gave better quality (10 cycles produced a quiet but audible background tone coming from some kind of harmonic --
perhaps an interaction with the every-64-cycle "long cycle" of the Apple II).  The initial version of ][-Sound used this
approach (and also used the "spare" 4 cycles for a page-flipping trick to visualize the audio bitstream while playing).

We can also use another trick to improve audio quality further: certain 65x02 opcodes will access memory multiple times
during execution (sometimes called "false reads").  For example, the INC $C030,X opcode executes for 7 cycles and will
access memory location $C030+X on cycles 4,5,6,7 (for values of X that do not result in page-crossing).  So by making
sure X=0 we can toggle the speaker 4 times in 7 cycles.

We use the following opcodes to cover all of the timing possibilities: NOP; STA $zp; STA $C030; STA $C030,X; INC $C030;
INC $C030,X

This improves audio quality by XXX%

## Player

The player consists of some ethernet setup code and a core playback loop of "player opcodes", which are the basic
operations that are dispatched to by the bytestream.

Some other tricks used here:

- The minimal 10-cycle (9-cycle) speaker loop is: STA $C030; JMP (WDATA), where we use an undocumented property of the
  Uthernet II: I/O registers on the WDATA don't wire up all of the address lines, so they are also accessible at
  other address offsets.  In particular WDATA+1 is a duplicate copy of WMODE.  In our case WMODE happens to be 0x3.
  This lets us use WDATA as a dynamic jump table into page 3, where we place our player code.  We then choose the
  network byte stream to contain the low-order byte of the target address we want to jump to next, and we'll
  indirect-jump to $03xx.

- There are many potential combinations of opcodes we could choose to produce patterns of speaker access.  If we limit
  to simple cases (e.g. 2 and 3-cycle padding opcodes, plus STA $C030) then the optimal solution can be easily
  constructed by hand, but this is infeasible when we include additional "exotic" choices like INC $C030.  Instead, we
  machine-generate this part of the player code.
  
- To do this, we compute all possible sequences of our candidate 65x02 opcodes up to maximum cycle count, and then
  determine the subset that allows access to the largest range of speaker trajectories, subject to the space constraint
  of fitting within page 3.  We also make of the property that the player can jump to any opcode within these sequences,
  which allows much greater coverage.

- By chaining together these "player opcodes", we can toggle the speaker with a wide variety of cycle patterns, though
  successive player opcodes always have a gap of at least 10 cycles between speaker toggles.  However even this cooldown
  gap amounts to 102.4KHz which is far beyond audible range. 

- As with my [\]\[-Vision](https://github.com/KrisKennaway/ii-vision) streaming video+audio player, we schedule a "slow
  path" dispatch to occur every 2KB in the byte stream, and use this to manage the socket buffers (ACK the read 2KB and
  wait until at least 2KB more is available, which is usually non-blocking).  While doing this we need to maintain a
  regular (non-audible) tick cadence so the speaker is in a known trajectory.  We can also partly compensate for this in
  the audio encoder. 

## Encoding

The encoder models the Apple II speaker as an RC circuit with given time constant and simulates it at 1MHz (i.e.
cycle-level) time resolution.

At every step we evaluate the possible next choices for the player, i.e. which player "opcode" we should branch to
next, considering the effect this will have on the speaker movement.  For example, an opcode that will run for 10 cycles
and invert the speaker voltage on cycle 4. 

To optimize the audio quality we look ahead some defined number of cycles (e.g. 20 cycles gives good results) and choose
a speaker trajectory that minimizes errors over this range, considering all possible sequences of opcodes that we could
choose to schedule during this cycle window.  This makes the encoding exponentially slower, but improves quality since
it allows us to e.g. anticipate large amplitude changes by pre-moving the speaker to better approximate them.

This also needs to take into account scheduling the "slow path" every 2048 output bytes, where the Apple II will manage
the TCP socket buffer while ticking the speaker at a constant cadence (currently chosen to be every 14 cycles XXX).  Since
we know this is happening we can compensate for it, i.e. look ahead to this upcoming slow path and pre-position the
speaker so that it introduces the least error during this "dead" period when we're keeping the speaker in a net-neutral
position.

```
$ ./encode_audio.py <input> <step size> <lookahead steps> <output.a2s>
```

where: 

*  `input` is the audio file to encode.  .mp3, .wav and probably others are supported.

*  `step size` is the fractional movement from current voltage to target voltage that we assume the Apple II speaker is
   making during each clock cycle.  A value of 500 (i.e. moving 1/500 of the distance) seems to be about right for my
   Apple //e.  This corresponds to a time constant of about 500us for the speaker RC circuit. XXX

*  `lookahead steps` defines how many cycles into the future we want to look when optimizing.  This is exponentially
   slower since we have to evaluate all possible sequences of player opcodes that could be chosen within the lookahead
   horizon.  A value of 20 gives good quality.

*  `output.a2s` is the output file to write to.

## Serving

This runs a HTTP server listening on port 1977 to which the player connects, then unidirectionally streams it the data.

```
$ ./play_audio.py <filename.a2s>
```

# Theory of operation

When we access $C030 it inverts the applied voltage across the speaker, and left to itself this results in an audio
"click".  When we invert the applied voltage, the speaker initially responds by moving asymptotically towards
the new voltage level, before developing oscillations that decay in amplitude over the following few milliseconds.

Electrically, the speaker behaves like an [RLC circuit](https://en.wikipedia.org/wiki/RLC_circuit), and the change in
applied voltage produces an oscillating audio waveform.  (Actually this seems to be an approximation, and the actual
audio output looks more like the sum of _two_ RLC circuits, with different frequencies - I'd like to understand this
better)

If we actuate the speaker frequently enough, these oscillations don't have time to develop and we can ignore them, so
the modeling becomes simpler.  This amounts to approximating the RLC circuit by an
[RC circuit](https://en.wikipedia.org/wiki/RC_circuit) which is easier to simulate.

With some empirical tuning of the time constant of this RC circuit, we can accurately model how the Apple II speaker
will respond to voltage changes, and use this to make the speaker "trace out" our desired waveform.  We can't do this
exactly -- the speaker will zig-zag around the target waveform because we can only move it in finite jumps -- so there
is some left-over "quantization noise" that manifests as background static, though in our case this is barely noticeable.

In practise the resulting audio also sometimes contains clicks or "crackling".  This problem is also found in other
Apple II audio playback techniques (e.g. PWM) and (from looking at audio waveforms) it seems to be due to the speaker
falling over into the non-linear oscillation mode.  i.e. we haven't successfully managed to keep it in the linear
regime.  Perhaps it will be necessary to model the full RLC circuit behaviour to control for this.

## Future work

### Ethernet configuration

Hard-coding the ethernet config is not especially user friendly.  This should be configurable at runtime.

### 6502 support

The player relies heavily on the JMP (indirect) 6502 opcode, which has a different cycle count on the 6502 (5 cycles)
and 65c02 (6 cycles).  This means the player will be about 10% **faster** on a 6502 (e.g. II+, Unenhanced //e), but audio
quality will be off until the encoder is made aware of this and able to compensate.

This might be one of the few pieces of software for which a 65c02 at the same clock speed causes a measurable
performance degradation (adding almost a minute to playback of an 8-minute song, until I compensated for it).

Hat tip to Scott Duensing who noticed that my sample audio sounded "a tad slow", which turned out to be due to this
1-cycle difference!

### Better encoding performance

The encoder is written in Python and is about 30x slower than real-time at a reasonable quality level.  Further
optimizations are possible but rewriting in e.g. C++ should give a large performance boost.

### Modeling as RLC circuit

Modeling the full RLC circuit behaviour may give insight into the "crackling" audio behaviour, and/or allow for better
controlling this.  As this is a second-order differential equation the simulation will be more complex and therefore
slower.

### In-memory playback

This level of audio quality requires high bit rate, about 85KB/sec.  So 1 minute of audio requires about 5MB of data.

A "Slinky" style memory card (RamFactor etc) uses a very similar I/O mechanism to the Uthernet II, i.e a $C0xx address
that auto-increments through the onboard memory space.  So it should be straightforward to extend ][-Sound to support
RamFactor playback (I don't have one though).

Playback from bank-switched memory (e.g. RamWorks) should also be feasible, though would require a small amount of 
extra code to add the player opcode to switch banks.

The other option is to reduce bitrate (and therefore audio quality).  Existing in-memory delta modulation players exist,
e.g. Oliver Schmidt's [PLAY.BTC](https://github.com/oliverschmidt/Play-BTc), though tooling for producing well-optimized
audio data for them did not exist.  It should be possible to adapt the ][-sound encoder to produce better-quality audio
for these existing players.

I think it should also be possible to improve in-memory playback quality at similar bitrate, through using some of the
cycle-level targeting techniques (though perhaps not at full 1-cycle resolution).