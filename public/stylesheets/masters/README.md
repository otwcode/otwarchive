# Guide

This folder contains CSS files for user skins that are loaded into the development database using the provided rake tasks. The skins can be organized into two categories:
- **Top-Level Skins**: Located in the `top_level/` subdirectory. Skins that are added to the skin chooser and subsequently cached.
  - Preview images for skins should be placed in the `previews/` subdirectory. If no preview is provided, the default preview image will be used.
- **Parent-Only Skins**: Located in the `parent_only/` subdirectory. Skins that are used as parent components for top-level skins.

## Rake tasks

### Load user skins
```bash
rake skins:load_official_skins
```
This task will:
- Prompt you whether to replace existing skins (`y/n`).
- Load top-level skins from the main directory and adds them to the skin chooser.
- Load parent-only skins from the `parent_only/` directory.

### Cache skins in skin chooser
```bash
rake skins:cache_chooser_skins
```
This task caches all skins marked as `in_chooser` and the default skin.

## Syntax for skin files

Each CSS file represents a single skin. The title of the skin should be specified at the top of the file:
```css
/* SKIN: My Awesome Skin */
```

### Parent Relationships
Skins can specify parent relationships using the `/* PARENTS: */` comment. Parents can be listed by title or by ID for default site skin components:

```css
/* PARENTS: Dark Mode - Midsize, Dark Mode - Screen */
```
or
```css
/* PARENTS: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31 */
```

### Additional Metadata
Skins can include optional metadata:
- **Description**: Add a description using the `/* DESCRIPTION: */` comment.
- **Media Queries**: Specify media queries using the `/* MEDIA: ... */` or `/* MEDIA: ... ENDMEDIA */`comment.

Example:
```css
/* SKIN: Lorem Ipsum */
/* DESCRIPTION: This skin serves an important purpose. */
/* PARENTS: Snow */
/* MEDIA: only screen and (max-width: 62em) ENDMEDIA */
```
