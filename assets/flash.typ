// set --ppi 120 for 1920x1080 output
#import "names.typ": det
#import "@preview/oxifmt:1.0.0": strfmt
#let codepoint = int(sys.inputs.at("t", default: 0x4ee0))
#let (col, block) = det(codepoint)
#let colour = (
  red,
  blue,
  green,
  yellow,
  purple,
  orange,
  maroon,
  olive,
  aqua,
  fuchsia,
  eastern,
  teal,
).at(calc.rem(col, 12))
#set text(font: ("Sarasa UI SC", "Unifont"), size: 5in, fill: colour.mix(black), weight: 800)
#set page(width: 16in, height: 9in, fill: colour.mix(gray))
#place(center + horizon, str.from-unicode(codepoint))
#place(bottom + left, text(size: .6in, [
  #strfmt("U+{:04X}", codepoint)\
  #block
]))
