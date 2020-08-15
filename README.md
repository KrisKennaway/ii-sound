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

The resulting bytestream directs the Apple II to follow this speaker trajectory with cycle-level precision.

The actual audio playback code is small enough to fit in page 3.  i.e. would have been small enough to type in from a
magazine back in the day (the megabytes of audio data would have been hard to type in though).  Plus, Uthernets didn't
exist back then (although a Slinky RAM card would let you do something similar, see Future Work below).

# Implementation

## Player

The audio player uses [delta modulation](https://en.wikipedia.org/wiki/Delta_modulation) to produce the audio signal.

How this works is by modeling the Apple II speaker as an [RC circuit](https://en.wikipedia.org/wiki/RC_circuit).  When
we tick the speaker (access $C030) it inverts the applied voltage across it, and the speaker responds by moving
asymptotically towards the new applied voltage level.  With some empirical tuning of the time constant of this RC
circuit, we can precisely model how the Apple II speaker will respond to voltage changes, and use this to make the
speaker "trace out" our desired waveform.  We can't do this exactly so there is some left-over quantization noise that
manifests as background static.

Delta modulation with an RC circuit is also called "BTC", after https://www.romanblack.com/picsound.htm who described
a number of variations on these (Apple II-like) audio circuits and Delta modulation audio encoding algorithms.  See e.g.
Oliver Schmidt's [PLAY.BTC](https://github.com/oliverschmidt/Play-BTc) for an Apple II implementation that plays from
memory.

The big difference with our approach is that we are able to target a 1-cycle resolution, i.e. modulate the audio at
1MHz.  The caveat is that we once we toggle the speaker there is a "cooldown period" of 10 cycles (9 cycles on 6502)
until we can toggle it again, though we can target any period larger than 11 (i.e. possible values are every 10, 12, 13,
14, ... cycles).  Successive choices are independent.

In other words, we are able to choose a precise sequence of clock cycles in which to toggle the speaker, but these
cannot be spaced too close together.

This minimum period of 10 cycles is already short enough that it produces high-quality audio even if we only modulate
the speaker at a fixed cadence of 10 cycles (i.e. at 102.4KHz), although in practice a fixed 14-cycle period gave better
audio (10 cycles produces a quiet but audible background tone coming from some kind of harmonic).  The initial version
of ][-Sound used this approach (and used the "spare" 4 cycles for a page-flipping trick to visualize the audio bitstream
while playing).

The player consists of some ethernet setup code and a core playback loop of "player opcodes", which are the 

Some other tricks used here:

- The minimal 10-cycle (9-cycle) speaker loop is: STA $C030; JMP (WDATA), where we use an undocumented property of the
  Uthernet II: I/O registers on the WDATA don't wire up all of the address lines, so they are also accessible at
  other address offsets.  In particular WDATA+1 is a duplicate copy of WMODE.  In our case WMODE happens to be 0x3.
  This lets us use WDATA as a jump table into page 3, where we place our player code.  We then choose the network
  byte stream to contain the low-order byte of the target address we want to jump to next.

- We prepend runs of 2 or 3-cycle padding opcodes (NOP, dummy 3-cycle store) to allow jumping into an opcode at
  various entry points to give additional delay variants.
  
- The choice of cycle lengths for the delay+tick and delay-only opcodes is such that we can obtain any delay period
  between speaker ticks (except <10, or 11) by chaining them together.

- As with my [\]\[-Vision](https://github.com/KrisKennaway/ii-vision) streaming video+audio player, we schedule a "slow
  path" dispatch to occur every 2KB in the byte stream, and use this to manage the socket buffers (ACK the read 2KB and
  wait until at least 2KB more is available, which is usually non-blocking).  While doing this we need to maintain the
  13 cycle cadence so the speaker is in a known trajectory.  We can compensate for this in the audio encoder.

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
the TCP socket buffer while ticking the speaker at a constant cadence (currently chosen to be every 13 cycles).  Since
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
   Apple //e.  This corresponds to a time constant of about 500us for the speaker RC circuit.

*  `lookahead steps` defines how far into the future we want to look when optimizing.  This is exponentially slower
   since we have to evaluate all 2^N possible combinations of tick/no-tick.  A value of 15-20 gives good quality.

*  `output.a2s` is the output file to write to.

## Serving

This runs a HTTP server listening on port 1977 to which the player connects, then unidirectionally streams it the data.

```
$ ./play_audio.py <filename.a2s>
```

## Future work

### Ethernet configuration

Hard-coding the ethernet config is not especially user friendly.  This should be configurable at runtime.

### 6502 support

The player relies heavily on the JMP (indirect) 6502 opcode, which has a different cycle count on the 6502 (5 cycles)
and 65c02 (6 cycles).  This means the player will be about 10% faster on a 6502 (e.g. II+, Unenhanced //e), but audio
quality will be off until the encoder is made aware of this and able to compensate.

This might be one of the few pieces of software for which a 65c02 at the same clock speed causes a measurable
performance degradation (adding almost a minute to playback of an 8-minute song, until I compensated for it)

### Better encoding performance

The encoder is written in Python and is about 30x slower than real-time at a reasonable quality level.  Further
optimizations are possible but rewriting in e.g. C++ should give a large performance boost.

### Better quality?

We can tick the speaker more frequently than 10 cycles using a couple of methods:

- chaining multiple STA $C030 together, e.g. to give a 4/.../4/4/9 cadence.

- by exploiting 6502 "false reads".  During the course of executing a 6502 opcode, the CPU may access memory locations
  multiple times (up to 4 times, during successive clock cycles).  This would give additional options for (partial)
  control of the speaker in the <10-cycle period regime.
  
It remains to be seen to what extent these approaches may effect audio quality.

### Measure speaker time constants

It would be interesting to measure the time constant of the speaker circuit directly (e.g. via oscilloscope) instead
of tuning by ear by picking a value whose output "sounds best".

Different Apple II models may well have different speaker characteristics - so far I've only tested on a single //e.

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

I think it should also be possible to improve quality at similar bitrate, through using some of the cycle-level targeting
techniques (though perhaps not at full 1-cycle resolution).