# Reversi Overview

Reversi is a dark theme with white text on a dark grey background. It has blue
accents and branding in place of red.

Reversi favors maintainability over brevity. To avoid introducing
cascade-related bugs, we prefer to adhere to the order laid out in the default
stylesheets and avoid reordering selectors or combining similar rule-sets. This
means you might notice a lot of rule-sets where the only declaration is
`color: #fff`, but that's by design -- combining them quickly leads to modifying
selectors, which in turn means the style might not be applied everywhere it is
needed.

If you add a new color-related declaration to the default skin, the pull request
must include a similar change for Reversi. Similarly, if you change the
selectors on a rule-set that includes color-related declarations, your pull
request should make the same change to the corresponding rule-set for Reversi. 

# Reversi Structure

Reversi consists of three skins.

## Reversi - Screen

The "Reversi - Screen" skin contains the majority of styles. It is used on all
screen sizes.

* Use the CSS from reversi_site_screen_.css.
* Expand the "Advanced" section.
* Check "Parent Only."

## Reversi - Midsize

The "Reversi - Midsize" skin contains adjustments for screens less than
62em in width.

* Use the CSS from reversi_midsize.handheld_.css.
* Expand the "Advanced" section.
* Check "Parent Only."
* For "Media," check the "only screen and (max-width: 62em)" option.

## Reversi

The "Reversi" skin combines the two previous skins so they can be used.

* Do not include any CSS.
* Expand the "Advanced" section.
* Press the "Add parent skin" button.
* For Parent #1, enter "Reversi - Screen".
* Press the "Add parent skin" button again.
* For Parent #2, enter "Reversi - Midsize."
