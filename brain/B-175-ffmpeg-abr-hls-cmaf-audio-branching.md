---
id: B-175
tags: [ffmpeg, media, gotcha, code]
scope: any FFmpeg ABR HLS/CMAF packager
hook: No single static FFmpeg HLS recipe handles both audio and video-only input — branch the audio maps AND var_stream_map; plus the CMAF/fMP4 recipe and a local both-inputs test method
---

# FFmpeg ABR HLS/CMAF: audio-vs-video-only branching + CMAF recipe

**The trap:** `-map 0:a:0` per rung + `var_stream_map "v:0,a:0,name:720p ..."` works for A/V input but
**aborts on a video-only publisher** ("Stream map '0:a:0' matches no streams"). Making audio optional
(`0:a:0?`) OR dropping `a:` from var_stream_map then breaks the OTHER case ("Unable to find mapping
variant stream"). The audio `-map` count AND the `a:i` slots in `var_stream_map` must BOTH match audio
presence. **There is no single static recipe for both** (empirically verified) — you must branch:

- audio present → maps `-map 0:a:0` per rung + `v:i,a:i,name:...`
- video-only   → no audio map + `v:i,name:...` (no `a:`)

Dead ends: `anullsrc` silent fallback works but *replaces* real audio; `amix [0:a][silence]` needs
`[0:a]` to exist (fails video-only) and with the infinite anullsrc listed first + `duration=first` it
**hangs forever**. Real per-stream fix = detect audio presence before spawning ffmpeg (lazy spawn); a
deployment env knob (e.g. `INGEST_AUDIO=0`) is the cheap mitigation.

**CMAF/fMP4** (shared container for HLS/LL-HLS/DASH):
`-hls_segment_type fmp4 -hls_fmp4_init_filename init.mp4 -hls_segment_filename %v/seg_%05d.m4s`
→ EXT-X-VERSION:7 master + per-variant `init_N.mp4` (referenced via `#EXT-X-MAP`) + `.m4s` segments.
Serve `.m4s`/`.mp4` as `video/mp4`. Player (hls.js) handles fMP4.

**Test method (do this before shipping a recipe change):** ffmpeg is a real dep — generate both
fixtures and run the exact args locally:
`ffmpeg -f lavfi -i testsrc -f lavfi -i sine -t 3 -c:v libx264 -c:a aac -shortest -f flv av.flv` and a
video-only one (no sine/`-c:a`); pipe each into the recipe; assert master + segments produced (exit 0).
**zsh gotcha:** unquoted `$ARGS` does NOT word-split — use `${=ARGS}` or an array, else the whole
string becomes one argv.
