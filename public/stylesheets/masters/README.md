# Reversi

Reversi is a dark theme, with white text on a dark grey background. It has blue
accents and branding in place of red.

It consists of three skins.

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

The "Reversi" skin combines the other skins.

* Do not include any CSS.
* Expand the "Advanced" section.
* Press the "Add parent skin" button.
* For Parent #1, enter "Reversi - Screen".
* Press the "Add parent skin" button again.
* For Parent #2, enter "Reversi - Midsize."
