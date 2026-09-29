# ICA 06 Critical Thinking (Undergraduate)

**Student:** Uyiosa Nehikhuere
**Prompt:** Measure and improve your smile arc

## 1. Sketch of the measurements (before coding)

```
            canvas (0,0) top-left
   +------------------------------------+
   |                                    |
   |           .-""""""""-.             |
   |         /   o      o   \           |   eyes: c.dx +/- r*eyeGap, c.dy - r*0.18
   |        |        c       |          |   c = (size.width/2, size.height/2)
   |        |  [====rect====]|          |   mouth corners on y = c.dy + r*0.35
   |         \    \______/  /           |
   |           '-.______.-'             |   r = size.shortestSide * 0.36
   +------------------------------------+
```

| Value | Formula | Example on a 360 x 300 canvas (r = 108) |
|---|---|---|
| Face center `c` | `Offset(size.width / 2, size.height / 2)` | (180, 150) |
| Face radius `r` | `size.shortestSide * 0.36` | 108 |
| Mood curve `k` | `(mood - 0.5) * 2`, from -1 (sad) to 1 (happy) | mood 0.8 gives k = 0.6 |
| Mouth `Rect` width | `r * 1.1` | 118.8 |
| Mouth `Rect` height | `r * (0.06 + 0.64 * k.abs())` | 47.9 |
| Mouth `Rect` center (smile) | `Offset(c.dx, c.dy + r * 0.35)` | (180, 187.8) |
| Start angle (smile) | `0` (3 o'clock) | 0 rad |
| Sweep angle (smile) | `pi` (clockwise through 6 o'clock) | 3.14 rad |
| Start / sweep (frown) | `pi` / `pi`, rect moved down by `height / 2` | 3.14 / 3.14 rad |

## 2. Response

My smile is balanced because the mouth `Rect` is built with `Rect.fromCenter` at `c.dx`, so the left and right corners are always the same distance from the face center, and `drawArc(rect, 0, pi, false, paint)` draws exactly the bottom half of that ellipse, so both corners land on the same line (`c.dy + r * 0.35`). Every mouth value comes from `r` (which comes from `size.shortestSide`) instead of fixed pixels, so on a small phone or a tablet the mouth width is always 1.1 times the radius and the curve depth is always the same proportion of the face. The mood slider changes only the ellipse height through `k`, and a frown reuses the same rectangle flipped to the top half (`start = pi`), shifted down by half its height so the frown stays in the same mouth area instead of jumping up toward the eyes.

To keep it responsive in landscape I made two changes. First, the radius uses `size.shortestSide` instead of `size.width`, because in landscape the width is much larger than the height and `size.width * 0.4` would push the top and bottom of the face off the canvas. I also lowered the factor from 0.40 to 0.36 so the hat accessory, which sits above the face, still fits. Second, the screen uses a `LayoutBuilder`: in portrait the face sits above the controls in a `Column`, and in landscape it switches to a `Row` with the face on the left and the scrollable controls on the right, so there is no overflow stripe on short landscape screens.

`shouldRepaint` returns `true` when the mood changes because the mouth geometry and face color both depend on `mood`, so the old pixels are now wrong and `paint()` must run again. It returns `false` when the inputs are the same because redrawing identical pixels wastes work on every rebuild (for example when a SnackBar appears and the parent rebuilds). My painter holds one `FaceConfig`, and its `==` compares every field the painter uses (type, mood, eye size, eye gap, blush, and each accessory), so `oldDelegate.config != config` repaints exactly when something visible changed. The unit test in `test/widget_test.dart` checks both cases.

## 3. Evidence

Add screenshots from the phone emulator here after running the app:

- `docs/portrait.png` (Pixel emulator, portrait, mood near 0.8)
- `docs/landscape.png` (same emulator rotated to landscape)

## 4. Success criteria check

- [x] Smile arc is centered and uses `drawArc`
- [x] Mouth coordinates are based on `size` or `radius`
- [ ] Portrait and landscape results tested on the phone emulator (add screenshots above)
- [x] I can explain the `shouldRepaint` decision
