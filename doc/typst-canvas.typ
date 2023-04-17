#import "../canvas.typ": *

#set page(paper: "a4")

#let example(canvas, code) = table(columns: (1fr, 4fr),
                                   align: (x, y) => (center, left).at(x),
                                   fill: (x, y) => (orange.lighten(95%), blue.lighten(95%)).at(x), stroke: none,
  block(inset: 1em, canvas),
  block(inset: 1em, code))

= Typst Canvas

== Draw Commands

=== line
Draw a path of at least two points.

==== Arguments
- mark-begin (string) Mark placed on line start.
- mark-end (string) Mark placed on line end.
- cycle (bool) : If true, close the path (connect start and end).
  Defaults to `false`.

#example(
canvas(length: 1.2em, {
    import "../draw.typ": *
    line((0, -0), (3, -0))
    line((0, -1), (3, -1), mark-end: ">")
    line((0, -2), (3, -2), mark-begin: ">")
    line((0, -3), (3, -3), mark-begin: ">", mark-end: ">")
    line((0, -4), (1, -4.5), (2, -3.5), (3, -4))
    line(cycle: true, (0, -5), (1, -5.5), (2, -4.5), (3, -5))
}),
```typst
line((0,  0), (1,  0))
line((0, -1), (3, -1), mark-end: ">")
line((0, -2), (3, -2), mark-begin: ">")
line((0, -3), (3, -3), mark-begin: ">", mark-end: ">")
line((0, -4), (1, -4.5), (2, -3.5), (3, -4))
line(cycle: true, (0, -5), (1, -5.5), (2, -4.5), (3, -5))
```
)

=== rect

#example(
canvas(length: 1em, {
    import "../draw.typ": *
    rect((0, 0), (1, 1))
}),
```typst
rect((0, 0), (1, 1))
```
)

=== fill
Set current fill color.

==== Arguments
- color (positional) (color) Color to set

=== stroke
Set current stroke style.

==== Arguments
- stroke (positional) (stroke) Stroke to set
