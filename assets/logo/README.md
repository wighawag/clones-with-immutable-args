# clones-with-immutable-args logo

The mark is one Ethereum-style diamond drawn three times: two outlined copies flanking a solid original. That is the library in a picture, a single implementation and its clones, all the same shape. The cyan segments at the belt are the immutable arguments, cut into the copy itself rather than stored beside it, which is the whole point of the technique: the args live in the clone's code region, not in storage.

Three clones, three argument slots. At small sizes the slots merge into one bar, which is why the favicon cut draws them that way to begin with.

The wordmark splits the way the name does: `clones` in ink, `with immutable args` in the mark's violet.

Everything is drawn from paths and primitives, so each file is self-contained: no fonts, no external references, no raster embeds, and no `var()` (which some rasterisers silently drop).

## Files

| File | Use |
| --- | --- |
| `cwia-mark.svg` | Primary mark, 256x256. Violet and cyan, so it sits on light and dark alike. |
| `cwia-mark-mono.svg` | One colour, inherits `currentColor`. The argument slots become holes in the solid clone. |
| `cwia-wordmark.svg` | Horizontal lockup on light backgrounds. |
| `cwia-wordmark-dark.svg` | Horizontal lockup on dark backgrounds. |
| `cwia-wordmark-mono.svg` | Horizontal lockup in one colour, inherits `currentColor`. |
| `cwia-favicon.svg` | Small-size cut: heavier strokes and one solid argument bar instead of three slots. Use below 48px, where the slots smear shut. |
| `preview.svg` / `preview.png` | 1280x640 social card (GitHub repo preview, OG image). The PNG is generated from the SVG. |

The wordmark letters are outlined geometry, not text, so nothing depends on an installed font and the file rasterises identically everywhere.

## Colours

- Clone outlines: `#A79BF5`.
- Original, left facet `#8B7CF0`, right facet `#5B49D8`.
- Immutable args: `#22C7D6`.
- Wordmark ink: `#1B2133`, or `#F3F1FF` on dark; the `with immutable args` line is `#6D5AE6`, or `#A79BF5` on dark.
- Card ink: `#12172A`.

## Using it

Dark-mode-aware README or docs page:

```html
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/logo/cwia-wordmark-dark.svg">
  <img alt="clones with immutable args" src="assets/logo/cwia-wordmark.svg" width="360">
</picture>
```

The mono variants take their colour from CSS, so they follow the surrounding text. That only works when the SVG is inlined in the document; an `<img>` tag isolates it and the mark renders black. Inline the file, or set `fill` yourself, when you need it tinted.

Favicon:

```html
<link rel="icon" href="/cwia-favicon.svg" type="image/svg+xml">
```

## Rasterising

```sh
inkscape cwia-mark.svg -o cwia-mark-512.png -w 512
```

The social card is the one file that has to ship as a raster, since GitHub and the OG scrapers will not take an SVG. Regenerate it from its source after any change to the lockup:

```sh
inkscape preview.svg -o preview.png -w 1280 -h 640
```

## Room to move

Keep clear space of at least one argument slot (26 units in the 256 grid) on every side. Do not restretch the lockup, respace the clones, or set the wordmark in a real font: the outlines are the wordmark. If you need the mark below 48px, switch to the favicon cut rather than scaling the primary down.
