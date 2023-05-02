#import "../canvas.typ": *

#let symbols = (
  /* staff bars */
  bar: (
    bar: "\u{1D100}",
    double: "\u{1D101}",
    double-bold: "\u{1D102}",
    bold-double: "\u{1D103}",
  ),

  /* clefs */
  clef: (
    treble: "\u{1D11E}",
    alto: none,
    bass: none,
  ),

  /* notes */
  note: (
    "0":  none,
    "1":  "\u{1D15D}",
    "2":  "\u{1D15E}",
    "4":  "\u{1D15F}",
    "8":  "\u{1D160}",
    "16": "\u{1D161}",
    "32": "\u{1D162}",
    "64": "\u{1D163}",
  ),

  /* accidentals */
  accidental: (
    "b": "\u{266D}", // flat
    "#": "\u{266F}", // sharp
    "N": "\u{266E}", // natural
  ),
)

#let absolute-pitch(note) = {
  assert(type(note) == "string", message: "Note name must be of type string.")
}

/** Parse pitch of format:
 *  Absolute:
 *    <note-name><octave>
 *  Relative:
 *    <note-name>[,']*
 */
#let parse-pitch(str, relative-to: 4) = {
  assert(type(str) == "string")

  let p = (
    c: 0, d: 1, e: 2, f: 3, g: 4, a: 5, b: 6
  )

  let m = str.match(regex("^([cdefgab])(b|#|N)*([0-9])?(:[0-9]+)?$"))
  if m != none {
    let (pitch, accidental, octave, length) = m.captures
    if octave == none {octave = 4}
    if length == none {length = 1} else {length = length.slice(1)}
    if pitch != none {
      pitch = p.at(pitch)
    }
    return (int(pitch), accidental, int(octave), length)
  }

  let m = str.match(regex("^([cdefgab])(b|#|N)*(,*|'*)(:[0-9]+)?$"))
  if m != none {
    let (pitch, accidental, octave, length) = m.captures
    if octave == none {octave = relative-to} else {
      octave = if (octave.at(0) == "'") {1} else {-1} * octave.len()
      octave += relative-to
    }
    if length == none {length = 1} else {length = length.slice(1)}
    if pitch != none {
      pitch = p.at(pitch)
    }
    return (int(pitch), accidental, int(octave), length)
  }
}

#let typst-scale = scale

#set text(size: 1cm)
#canvas({
  import "../draw.typ": *

  let pitch-position(pitch, octave) = {
    let add(note, current, staff-low, staff-high) = {
      return (current.at(0),
              (staff-high.at(1) - staff-low.at(1)) / 8 * (note - 2),
              0)
    }

    pitch = (octave - 4) * 7 + pitch
    move-to((add, pitch, (), "staff-low", "staff-high"))
  }

  let skip(length: 1) = {
    let advance-x(x, current, staff-low, staff-high) = {
      return (current.at(0) + x, staff-low.at(1))
    }

    move-to((advance-x, length, (), "staff-low", "staff-high"))
    anchor("current-low", ())
  }

  let place-element(sym, relative-to: 4) = {
    if sym == "|" {
      move-to("current-low")
      content((), [#symbols.bar.bar], anchor: "below")
    } else if sym == "&g" {
      let (pitch, ..) = parse-pitch("g4")
      pitch-position(pitch, 4)
      content((), [#symbols.clef.treble], anchor: "below")
      skip(length: 1.4)
    } else {
      let (pitch, accidental, octave, length) = parse-pitch(
        sym, relative-to: relative-to)


      if accidental != none {
        for acc in accidental {
          pitch-position(pitch, octave)
          if acc == "b" {
            // fix: the unicode symbol seems to have a weird baseline
            pitch-position(pitch + 1, octave)
          }
          content((), typst-scale(y: 150%)[#symbols.accidental.at(acc)], anchor: "right")
          skip(length: .2)
        }
      }

      pitch-position(pitch, octave)
      content((), [#symbols.note.at(str(length))], anchor: "below")
      skip()
    }
  }

  let staff(relative-to: "c4", ..symbols) = group({
    anchor("staff-low",  (rel: (0, 0)))
    anchor("staff-high", (rel: (0, 1)))

    let (_, _, octave, ..) = parse-pitch(relative-to)

    for r in range(0, 5) {
      line((0, r / 4), (10, r / 4), name: "line-" + str(r))
    }

    move-to("staff-low")
    skip(length: .6)

    for sym in symbols.pos() {
      place-element(sym, relative-to: octave)
    }
  })

  staff("&g", "ab", "g", "e", "b", "f#", "aN", "eN", "bb", "db'", "c", "eb", "d")
})
