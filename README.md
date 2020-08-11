# ][-Sound

Delta modulation audio player for streaming audio over Ethernet, for the Apple II.

Requires:
*  Uthernet II (currently assumed to be in slot 1)
*  Any Apple II (would probably even work with 16K)

NOTE: Ethernet addresses are hardcoded to 10.0.0.1 for the server and 10.0.65.02 for the Apple II.  This is not currently configurable without reassembling

## Player

This style of audio encoding is often called "BTC" in the Apple II community, after https://www.romanblack.com/picsound.htm who described various Apple II-like audio circuits and Delta modulation-like audio encoding algorithms.

How this works is by modeling the Apple II speaker as an [RC circuit](https://en.wikipedia.org/wiki/RC_circuit).  When we tick the speaker it inverts the voltage across it, and the speaker responds by moving asymptotically towards the new level.  With some empirical tuning of the time constant of this RC circuit, we can precisely model how the speaker will respond to voltage changes, and use this to make the speaker "trace out" our desired waveform.  We can't do this exactly so there is some left-over quantization noise that manifests as background static.

This player uses a 13-cycle period, i.e. about 78.7KHz sampling rate.  We could go as low as 9 cycles for the period, but there is an audible 12.6KHz harmonic that I think is due to interference between the 9 cycle period and the every-65-cycle "long cycle" of the Apple II CPU.  13 cycles evenly divides 65 so this avoids the harmonic.

Some other tricks used here:

- The minimal 9-cycle speaker loop is: STA $C030; JMP (WDATA), where we use an undocumented property of the
  Uthernet II: I/O registers on the WDATA don't wire up all of the address lines, so they are also accessible at
  other address offsets.  In particular WDATA+1 is a duplicate copy of WMODE.  In our case WMODE happens to be 0x3.
  This lets us use WDATA as a jump table into page 3, where we place our player code.  We then choose the network
  byte stream to contain the low-order byte of the target address we want to jump to next.
- Since our 13-cycle period gives us 4 "spare" cycles over the minimal 9, that also lets us do a page-flipping trick
  to visualize the audio bitstream while playing.
- As with my [\]\[-Vision](https://github.com/KrisKennaway/ii-vision) streaming video+audio player, we schedule a "slow path" dispatch to occur every 2KB in the
  byte stream, and use this to manage the socket buffers (ACK the read 2KB and wait until at least 2KB more is
  available, which is usually non-blocking).  While doing this we need to maintain the 13 cycle cadence so the
  speaker is in a known trajectory.  We can compensate for this in the audio encoder.

## Encoding

The encoder models the Apple II speaker as an RC circuit with given time constant
and computes a sequence of speaker ticks at multiples of 13-cycle intervals
to approximate the target audio waveform.

To optimize the audio quality we look ahead some defined number of steps and
choose a speaker trajectory that minimizes errors over this range.  e.g.
this allows us to anticipate large amplitude changes by pre-moving
the speaker to better approximate them.

This also needs to take into account scheduling the "slow path" every 2048
output bytes, where the Apple II will manage the TCP socket buffer while
ticking the speaker every 13 cycles.  Since we know this is happening
we can compensate for it, i.e. look ahead to this upcoming slow path and
pre-position the speaker so that it introduces the least error during
this "dead" period when we're keeping the speaker in a net-neutral position.

```
$ ./encode_audio.py <input> <step size> <lookahead steps> <output.a2s>
```

where: 

*  `input` is the audio file to encode.  .mp3, .wav and probably others are supported.
*  `step size` is the fractional movement from current voltage to target voltage that we assume the Apple II speaker is making in each 13-cycle period.  A value of 40 seems to be about right for my Apple //e.
*  `lookahead steps` defines how far into the future we want to look when optimizing.  This is exponentially slower since we have to evaluate all 2^N possible combinations of tick/no-tick.  Quality is already decent with 1, and hits diminishing returns around 12 (which takes several hours for typical songs).
*  `output.a2s` is the output file to write to.

## Serving

This runs a HTTP server listening on port 1977 to which the player connects, then unidirectionally streams it the data.

```
$ ./play_audio.py <filename.a2s>
```
