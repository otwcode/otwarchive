# Dark Mode Overview

Dark Mode is a dark theme with light text on a dark grey background. It has blue
accents and branding in place of red.

Dark Mode favors maintainability over brevity. To avoid introducing
cascade-related bugs, we prefer to adhere to the order laid out in the default
stylesheets and avoid reordering selectors or combining similar rule-sets. This
means you might notice a lot of rule-sets where the only declaration is
`color: #fff`, but that's by design -- combining them quickly leads to modifying
selectors, which in turn means the style might not be applied everywhere it is
needed.

If you add a new color-related declaration to the default skin, the pull request
must include a similar change for Dark Mode. Similarly, if you change the
selectors on a rule-set that includes color-related declarations, your pull
request should make the same change to the corresponding rule-set for Dark Mode.

# Dark Mode Structure

Dark Mode consists of three skins.

## Dark Mode - Screen

The "Dark Mode - Screen" skin contains the majority of styles. It is used on all
screen sizes.

* Use the CSS from dark_mode_site_screen_.css.
* Expand the "Advanced" section.
* Check "Parent Only."

## Dark Mode - Midsize

The "Dark Mode - Midsize" skin contains adjustments for screens less than
62em in width.

* Use the CSS from dark_mode_midsize_.css.
* Expand the "Advanced" section.
* Check "Parent Only."
* For "Media," check the "only screen and (max-width: 62em)" option.

## Dark Mode

The "Dark Mode" skin combines the two previous skins so they can be used. It has
placeholder CSS because the CSS field cannot be blank.

* Include the placeholder CSS `#unused-selector { content: none; }`.
* Expand the "Advanced" section.
* Press the "Add parent skin" button.
* For Parent #1, enter "Dark Mode - Screen".
* Press the "Add parent skin" button again.
* For Parent #2, enter "Dark Mode - Midsize."
