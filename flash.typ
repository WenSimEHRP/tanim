// set --ppi 120 for 1920x1080 output
#import "@preview/oxifmt:1.0.0": strfmt
#set page(width: 16in, height: 9in, fill: green.mix(gray))
#set text(font: ("Sarasa UI SC", "Unifont"), size: 5in, fill: green.mix(black), weight: 800)
#let codepoint = int(sys.inputs.at("a", default: 0x4ee0))
#place(center + horizon, str.from-unicode(codepoint))
#place(bottom + left, text(size: 1in, strfmt("U+{:04X}", codepoint)))
