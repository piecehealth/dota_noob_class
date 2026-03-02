# DaisyUI 5.x Complete Component CSS Reference

> Comprehensive reference for all 65 DaisyUI components — CSS classes, descriptions, variants, modifiers, sizes, and colors.
> Source: https://daisyui.com/components/ — DaisyUI v5.5+

---

# ACTIONS

## Button
> Clickable element for triggering actions, with extensive style, size, color, and shape variants.

| Class | Description |
|-------|-------------|
| `btn` | Core button component with default styling and padding |
| `btn-neutral` | Neutral color scheme |
| `btn-primary` | Primary brand color |
| `btn-secondary` | Secondary accent color |
| `btn-accent` | Accent highlight color |
| `btn-info` | Informational blue tone |
| `btn-success` | Success/positive green tone |
| `btn-warning` | Warning/caution yellow tone |
| `btn-error` | Error/danger red tone |
| `btn-outline` | Bordered button with transparent background |
| `btn-dash` | Dashed border style |
| `btn-soft` | Subtle background with muted colors |
| `btn-ghost` | Minimal styling, appears as text initially |
| `btn-link` | Appears as hyperlink styling |
| `btn-xs` | Extra small dimensions |
| `btn-sm` | Small size |
| `btn-md` | Medium size (default) |
| `btn-lg` | Large size |
| `btn-xl` | Extra large size |
| `btn-wide` | Increased horizontal padding |
| `btn-block` | Full width (100%) |
| `btn-square` | 1:1 aspect ratio, square shape |
| `btn-circle` | 1:1 aspect ratio with fully rounded corners |
| `btn-active` | Displays pressed/selected appearance |
| `btn-disabled` | Disabled state styling |

---

## Dropdown
> Container that reveals hidden content on click or hover, with flexible placement options.

| Class | Description |
|-------|-------------|
| `dropdown` | Main container component for dropdown functionality |
| `dropdown-content` | Wrapper for the dropdown menu/content that displays when triggered |
| `dropdown-start` | Aligns dropdown content to the start (left) horizontally (default) |
| `dropdown-center` | Centers dropdown content horizontally relative to the button |
| `dropdown-end` | Aligns dropdown content to the end (right) horizontally |
| `dropdown-top` | Opens dropdown menu upward from the button |
| `dropdown-bottom` | Opens dropdown menu downward (default) |
| `dropdown-left` | Opens dropdown menu to the left of the button |
| `dropdown-right` | Opens dropdown menu to the right of the button |
| `dropdown-hover` | Enables the dropdown to open on hover |
| `dropdown-open` | Forces the dropdown to remain open |
| `dropdown-close` | Forces the dropdown to remain closed |

---

## FAB (Floating Action Button / Speed Dial)
> Fixed-position floating button that reveals secondary action buttons on click.

| Class | Description |
|-------|-------------|
| `fab` | Main container for the floating action button; positions in bottom corner |
| `fab-close` | Optional wrapper for a close button shown when FAB opens |
| `fab-main-action` | Optional wrapper for an action button shown when FAB opens |
| `fab-flower` | Arranges speed dial buttons in a quarter-circle pattern (supports 1–4 buttons) |

---

## Modal
> Dialog overlay for displaying content that requires user attention or interaction.

| Class | Description |
|-------|-------------|
| `modal` | Main container/wrapper for the dialog |
| `modal-box` | Content wrapper that holds the dialog's main content |
| `modal-action` | Section for grouping action buttons within the modal |
| `modal-backdrop` | Overlay layer that closes modal on external click |
| `modal-toggle` | Hidden checkbox controlling open/closed state (legacy) |
| `modal-top` | Positions the modal at the top of the viewport |
| `modal-middle` | Centers the modal vertically (default) |
| `modal-bottom` | Positions the modal at the bottom of the viewport |
| `modal-start` | Aligns the modal to the start side horizontally |
| `modal-end` | Aligns the modal to the end side horizontally |
| `modal-open` | Keeps the modal visible (toggled via JavaScript) |

---

## Swap
> Toggles visibility between two elements using a checkbox or class, with animation effects.

| Class | Description |
|-------|-------------|
| `swap` | Main container enabling toggle visibility between two child elements |
| `swap-on` | Child element displayed when swap is active/checked |
| `swap-off` | Child element displayed when swap is inactive/unchecked |
| `swap-indeterminate` | Child element shown when checkbox is in indeterminate state |
| `swap-active` | Activates the swap without a checkbox (toggled via JavaScript) |
| `swap-rotate` | Applies a rotation animation during the swap transition |
| `swap-flip` | Applies a flip/mirror animation during the swap transition |

---

## Theme Controller
> Input-based component (checkbox, radio, toggle, button) that switches the page theme.

| Class | Description |
|-------|-------------|
| `theme-controller` | Enables theme switching on checkbox or radio inputs via the `value` attribute |

---

# DATA DISPLAY

## Accordion
> Collapsible sections that expand to reveal content, typically used in groups.

| Class | Description |
|-------|-------------|
| `collapse` | Main component wrapper; creates the collapsible container |
| `collapse-title` | Styles the clickable title/header of each accordion item |
| `collapse-content` | Styles the hidden content area that expands when open |
| `collapse-arrow` | Adds a rotating arrow indicator to show open/closed state |
| `collapse-plus` | Adds a plus/minus icon that toggles between states |
| `collapse-open` | Forces the accordion item to display in the open state |
| `collapse-close` | Forces the accordion item to display in the closed state |

---

## Avatar
> Displays a user profile image, initials placeholder, or grouped avatars with status indicators.

| Class | Description |
|-------|-------------|
| `avatar` | Main component wrapper for individual avatar elements |
| `avatar-group` | Container for grouping multiple overlapping avatars |
| `avatar-online` | Shows a green dot indicator for online status |
| `avatar-offline` | Shows a gray dot indicator for offline status |
| `avatar-placeholder` | Modifier for displaying text/initials as avatar fallback |

---

## Badge
> Small label for status, counts, or tags, with color and size variants.

| Class | Description |
|-------|-------------|
| `badge` | Base container element for badge component |
| `badge-neutral` | Neutral color scheme |
| `badge-primary` | Primary theme color |
| `badge-secondary` | Secondary theme color |
| `badge-accent` | Accent color |
| `badge-info` | Information status color |
| `badge-success` | Success status color |
| `badge-warning` | Warning status color |
| `badge-error` | Error status color |
| `badge-outline` | Outline style with border |
| `badge-dash` | Dashed outline style |
| `badge-soft` | Soft background style |
| `badge-ghost` | Ghost/transparent style |
| `badge-xs` | Extra small size |
| `badge-sm` | Small size |
| `badge-md` | Medium size (default) |
| `badge-lg` | Large size |
| `badge-xl` | Extra large size |

---

## Card
> Flexible container for grouping content with image, body, title, and action sections.

| Class | Description |
|-------|-------------|
| `card` | Main container component for grouping and displaying content |
| `card-title` | Heading element within the card body |
| `card-body` | Content wrapper holding title, text, and actions |
| `card-actions` | Container for buttons and interactive elements |
| `card-border` | Applies a solid border around the card |
| `card-dash` | Creates a dashed border style |
| `card-side` | Positions the figure/image to the left of content |
| `image-full` | Makes the figure element serve as the card background |
| `card-xs` | Extra small padding and spacing |
| `card-sm` | Small padding and spacing |
| `card-md` | Medium padding (default) |
| `card-lg` | Large padding and spacing |
| `card-xl` | Extra large padding and spacing |

---

## Carousel
> Horizontally or vertically scrollable container with snap-scrolling behavior.

| Class | Description |
|-------|-------------|
| `carousel` | Main container creating a scrollable carousel with snap behavior |
| `carousel-item` | Individual item within the carousel |
| `carousel-start` | Snaps items to the start/left position (default) |
| `carousel-center` | Snaps items to the center of the visible viewport |
| `carousel-end` | Snaps items to the end/right position |
| `carousel-horizontal` | Horizontally-scrolling carousel (default) |
| `carousel-vertical` | Vertically-scrolling carousel |

---

## Chat
> Speech bubble layout for conversation interfaces, with sender/receiver positioning.

| Class | Description |
|-------|-------------|
| `chat` | Container for one line of conversation |
| `chat-image` | Wraps the author's profile image or avatar |
| `chat-header` | Text displayed above the chat bubble (name, timestamp) |
| `chat-footer` | Text displayed below the chat bubble (delivery status) |
| `chat-bubble` | The main message container with speech bubble styling |
| `chat-start` | Positions chat bubble on the left side |
| `chat-end` | Positions chat bubble on the right side |
| `chat-bubble-neutral` | Neutral color theme for message bubble |
| `chat-bubble-primary` | Primary brand color for message bubble |
| `chat-bubble-secondary` | Secondary color for message bubble |
| `chat-bubble-accent` | Accent color for message bubble |
| `chat-bubble-info` | Info/blue color for message bubble |
| `chat-bubble-success` | Success/green color for message bubble |
| `chat-bubble-warning` | Warning/amber color for message bubble |
| `chat-bubble-error` | Error/red color for message bubble |

---

## Collapse
> Single collapsible section that shows/hides content on click, independent of accordion.

| Class | Description |
|-------|-------------|
| `collapse` | Main component container for the collapsible section |
| `collapse-title` | Styles the clickable header/title portion |
| `collapse-content` | Styles the hidden content area |
| `collapse-arrow` | Adds a rotating arrow icon to indicate open/closed state |
| `collapse-plus` | Adds a plus/minus icon instead of an arrow |
| `collapse-open` | Forces the collapse to remain open |
| `collapse-close` | Forces the collapse to remain closed |

---

## Countdown
> Animated number display that transitions between values, used for timers and countdowns.

| Class | Description |
|-------|-------------|
| `countdown` | Main wrapper that applies transition effect when numbers change (0–999) |

> Uses `--value` CSS variable to set the number and `--digits` for minimum digit count.

---

## Diff
> Side-by-side comparison component with a draggable resizer to reveal before/after content.

| Class | Description |
|-------|-------------|
| `diff` | Main container creating the side-by-side comparison layout |
| `diff-item-1` | First item container (left side of comparison) |
| `diff-item-2` | Second item container (right side of comparison) |
| `diff-resizer` | Interactive draggable control adjusting the divider position |

---

## Hover 3D
> Card container with a 3D tilt effect triggered by mouse position across hover zones.

| Class | Description |
|-------|-------------|
| `hover-3d` | Main wrapper enabling 3D tilt effect via mouse movement (requires 8 empty child divs) |

---

## Hover Gallery
> Image gallery where hovering horizontally reveals additional images without JavaScript.

| Class | Description |
|-------|-------------|
| `hover-gallery` | Container class creating a hover-reveal image gallery |

---

## KBD (Keyboard)
> Displays keyboard shortcuts styled to resemble physical keyboard keys.

| Class | Description |
|-------|-------------|
| `kbd` | Base class displaying keyboard shortcuts with styled borders and background |
| `kbd-xs` | Extra small size |
| `kbd-sm` | Small size |
| `kbd-md` | Medium size (default) |
| `kbd-lg` | Large size |
| `kbd-xl` | Extra large size |

---

## List
> Vertical layout for displaying information in structured rows with optional columns.

| Class | Description |
|-------|-------------|
| `list` | Main container for vertical list layout |
| `list-row` | Individual item inside a list; uses horizontal grid layout |
| `list-col-wrap` | Pushes a direct child of `list-row` to the next line |
| `list-col-grow` | Makes a direct child of `list-row` fill remaining space |

---

## Stat
> Displays statistical data with title, value, description, and optional figure/actions.

| Class | Description |
|-------|-------------|
| `stats` | Container wrapper for multiple stat items; creates a grid layout |
| `stat` | Individual stat block displaying a single data metric |
| `stat-title` | Text label describing what the stat represents |
| `stat-value` | Primary numeric or text value being displayed |
| `stat-desc` | Secondary descriptive text (comparison, time period, etc.) |
| `stat-figure` | Container for icons or visual elements alongside stats |
| `stat-actions` | Section for interactive buttons or controls within a stat |
| `stats-horizontal` | Arranges stats in a row (default) |
| `stats-vertical` | Stacks stats in a vertical column |

---

## Status
> Small indicator dot/icon for displaying element status such as online, offline, or error.

| Class | Description |
|-------|-------------|
| `status` | Core component class creating a small status indicator icon |
| `status-neutral` | Neutral color |
| `status-primary` | Primary theme color |
| `status-secondary` | Secondary theme color |
| `status-accent` | Accent theme color |
| `status-info` | Info/blue color |
| `status-success` | Success/green color |
| `status-warning` | Warning/amber color |
| `status-error` | Error/red color |
| `status-xs` | Extra small size |
| `status-sm` | Small size |
| `status-md` | Medium size (default) |
| `status-lg` | Large size |
| `status-xl` | Extra large size |

---

## Table
> Styled HTML table with zebra stripes, sticky rows/columns, and size variants.

| Class | Description |
|-------|-------------|
| `table` | Base component class applied to `<table>` for styling |
| `table-zebra` | Adds alternating row stripe colors |
| `table-pin-rows` | Makes `<thead>` and `<tfoot>` rows sticky during vertical scroll |
| `table-pin-cols` | Makes `<th>` columns sticky during horizontal scroll |
| `table-xs` | Extra small padding and font size |
| `table-sm` | Small padding and font size |
| `table-md` | Medium padding and font size (default) |
| `table-lg` | Large padding and font size |
| `table-xl` | Extra large padding and font size |

---

## Text Rotate
> Animates through a list of text items in a cycling rotation effect.

| Class | Description |
|-------|-------------|
| `text-rotate` | Main wrapper enabling rotating text animation cycling through child elements |

> Use `duration-{ms}` modifier (e.g., `duration-6000`) to control cycle speed. Default cycle is 10 seconds.

---

## Timeline
> Vertical or horizontal sequence of events with connectors and optional box styling.

| Class | Description |
|-------|-------------|
| `timeline` | Primary container creating the timeline layout structure |
| `timeline-start` | Positions content on the start/left side of timeline items |
| `timeline-middle` | Centers content (icons) in the middle of timeline items |
| `timeline-end` | Positions content on the end/right side of timeline items |
| `timeline-box` | Applies styled box container around timeline content |
| `timeline-snap-icon` | Anchors icons to the start position instead of centering |
| `timeline-compact` | Consolidates all items to a single side |
| `timeline-horizontal` | Arranges timeline items horizontally (left-to-right) |
| `timeline-vertical` | Stacks timeline items vertically (default) |

---

# NAVIGATION

## Breadcrumbs
> Navigation trail showing the user's current location within a hierarchy.

| Class | Description |
|-------|-------------|
| `breadcrumbs` | Main wrapper applying breadcrumb styling to a `<ul>` element |

---

## Dock
> Bottom-fixed navigation bar similar to a mobile app dock, with labels and active state.

| Class | Description |
|-------|-------------|
| `dock` | Container for the dock; sticks to the bottom of the screen |
| `dock-label` | Text label displayed for each dock item |
| `dock-active` | Styling for the currently active/selected dock item |
| `dock-xs` | Extra small dock sizing |
| `dock-sm` | Small dock sizing |
| `dock-md` | Medium dock sizing (default) |
| `dock-lg` | Large dock sizing |
| `dock-xl` | Extra large dock sizing |

---

## Link
> Styled anchor element with underline and color variants.

| Class | Description |
|-------|-------------|
| `link` | Base component adding underline styling to links |
| `link-hover` | Shows underline only on hover |
| `link-neutral` | Neutral color variant |
| `link-primary` | Primary theme color |
| `link-secondary` | Secondary theme color |
| `link-accent` | Accent color |
| `link-success` | Success state color |
| `link-info` | Info/informational color |
| `link-warning` | Warning state color |
| `link-error` | Error/danger state color |

---

## Menu
> Vertical or horizontal list of navigation links with optional submenus and size variants.

| Class | Description |
|-------|-------------|
| `menu` | Container for vertical or horizontal navigation links |
| `menu-title` | Styles a list item as a section title/header |
| `menu-dropdown` | Container for collapsible submenu items (hidden by default) |
| `menu-dropdown-toggle` | Toggle element to show/hide dropdown submenus via JavaScript |
| `menu-disabled` | Makes a menu item appear visually disabled |
| `menu-active` | Highlights the currently active/selected menu item |
| `menu-focus` | Applies focus styling to a menu item |
| `menu-xs` | Extra small spacing and text |
| `menu-sm` | Small spacing and text |
| `menu-md` | Medium spacing and text (default) |
| `menu-lg` | Large spacing and text |
| `menu-xl` | Extra large spacing and text |
| `menu-vertical` | Displays items in vertical stack (default) |
| `menu-horizontal` | Displays items in horizontal row |
| `menu-dropdown-show` | Reveals hidden dropdown menus via JavaScript |

---

## Navbar
> Top navigation bar with start, center, and end sections for flexible content layout.

| Class | Description |
|-------|-------------|
| `navbar` | Main container creating the navigation bar wrapper |
| `navbar-start` | Section positioned at the left side of the navbar |
| `navbar-center` | Section positioned at the center of the navbar |
| `navbar-end` | Section positioned at the right side of the navbar |

---

## Pagination
> Navigation controls for moving between pages, built with join and button components.

| Class | Description |
|-------|-------------|
| `join` | Container grouping multiple pagination items together |
| `join-item` | Individual item within the join container |
| `join-vertical` | Displays join items vertically |
| `join-horizontal` | Displays join items horizontally (default) |
| `btn-active` | Highlights the currently active/selected page |
| `btn-disabled` | Disables a page button (e.g., for ellipsis) |

---

## Steps
> Sequential step indicator showing progress through a multi-step process.

| Class | Description |
|-------|-------------|
| `steps` | Container holding multiple step nodes in sequence |
| `step` | Individual step node within the container |
| `step-icon` | Custom icon container inside a step element |
| `steps-vertical` | Arranges steps vertically (default) |
| `steps-horizontal` | Arranges steps horizontally |
| `step-neutral` | Neutral color scheme for a step |
| `step-primary` | Primary color scheme |
| `step-secondary` | Secondary color scheme |
| `step-accent` | Accent color scheme |
| `step-info` | Info color scheme |
| `step-success` | Success color scheme |
| `step-warning` | Warning color scheme |
| `step-error` | Error color scheme |

> Use `data-content` attribute on `<li>` to customize step indicator symbols.

---

## Tab
> Tabbed navigation interface for switching between content panels.

| Class | Description |
|-------|-------------|
| `tabs` | Main container for tab components |
| `tab` | Individual tab button/element |
| `tab-content` | Content area associated with a specific tab |
| `tabs-box` | Applies box-style appearance to tabs |
| `tabs-border` | Applies bottom border styling to tabs |
| `tabs-lift` | Applies lifted/elevated styling to tabs |
| `tabs-xs` | Extra small tab size |
| `tabs-sm` | Small tab size |
| `tabs-md` | Medium tab size (default) |
| `tabs-lg` | Large tab size |
| `tabs-xl` | Extra large tab size |
| `tabs-top` | Positions tab buttons above content (default) |
| `tabs-bottom` | Positions tab buttons below content |
| `tab-active` | Highlights the currently active/selected tab |
| `tab-disabled` | Visually disables a tab element |

---

# FEEDBACK

## Alert
> Notification banners for informational, success, warning, or error messages.

| Class | Description |
|-------|-------------|
| `alert` | Main container element for alert messages |
| `alert-outline` | Applies outline/border styling |
| `alert-dash` | Adds dashed border styling |
| `alert-soft` | Creates a softer, subtle appearance |
| `alert-info` | Blue informational alert |
| `alert-success` | Green success/confirmation alert |
| `alert-warning` | Yellow/amber warning alert |
| `alert-error` | Red error/failure alert |
| `alert-vertical` | Stacks alert content vertically |
| `alert-horizontal` | Arranges alert content horizontally |

---

## Loading
> Animated loading indicators with multiple animation styles, sizes, and colors.

| Class | Description |
|-------|-------------|
| `loading` | Core component class creating the loading animation element |
| `loading-spinner` | Rotating spinner animation |
| `loading-dots` | Animated dots animation |
| `loading-ring` | Rotating ring animation |
| `loading-ball` | Bouncing ball animation |
| `loading-bars` | Animated bars animation |
| `loading-infinity` | Infinity symbol animation |
| `loading-xs` | Extra small size |
| `loading-sm` | Small size |
| `loading-md` | Medium size (default) |
| `loading-lg` | Large size |
| `loading-xl` | Extra large size |

> Color via Tailwind text utilities: `text-primary`, `text-secondary`, `text-accent`, `text-neutral`, `text-info`, `text-success`, `text-warning`, `text-error`.

---

## Progress
> Linear progress bar for displaying task completion or loading state.

| Class | Description |
|-------|-------------|
| `progress` | Base class for the progress bar, applied to `<progress>` elements |
| `progress-primary` | Primary theme color |
| `progress-secondary` | Secondary theme color |
| `progress-accent` | Accent theme color |
| `progress-neutral` | Neutral theme color |
| `progress-info` | Info/blue color |
| `progress-success` | Success/green color |
| `progress-warning` | Warning color |
| `progress-error` | Error/red color |

> Omit the `value` attribute for an indeterminate animated state.

---

## Radial Progress
> Circular progress indicator built with CSS, supporting custom size and thickness.

| Class | Description |
|-------|-------------|
| `radial-progress` | Main component class creating a circular progress indicator |

> CSS variables: `--value` (0–100), `--size` (default: 5rem), `--thickness` (default: 10% of size).

---

## Skeleton
> Placeholder loading animation that mimics the shape of upcoming content.

| Class | Description |
|-------|-------------|
| `skeleton` | Primary class creating a placeholder div with loading animation |
| `skeleton-text` | Modifier that animates text color/gradient (shimmer on text) |

---

## Toast
> Fixed-position container for stacking notification messages in a corner of the viewport.

| Class | Description |
|-------|-------------|
| `toast` | Main container positioning elements in a corner of the page |
| `toast-start` | Aligns toast horizontally to the left |
| `toast-center` | Centers the toast horizontally |
| `toast-end` | Aligns toast to the right (default) |
| `toast-top` | Positions toast at the top vertically |
| `toast-middle` | Centers the toast vertically |
| `toast-bottom` | Positions toast at the bottom (default) |

---

## Tooltip
> Small informational popup displayed on hover or permanently, with placement and color variants.

| Class | Description |
|-------|-------------|
| `tooltip` | Main container wrapping the trigger and tooltip content |
| `tooltip-content` | Optional div for custom tooltip content (alternative to `data-tip`) |
| `tooltip-top` | Positions tooltip above the trigger (default) |
| `tooltip-bottom` | Positions tooltip below the trigger |
| `tooltip-left` | Positions tooltip to the left of the trigger |
| `tooltip-right` | Positions tooltip to the right of the trigger |
| `tooltip-open` | Forces the tooltip to remain visible |
| `tooltip-neutral` | Neutral color scheme |
| `tooltip-primary` | Primary theme color |
| `tooltip-secondary` | Secondary theme color |
| `tooltip-accent` | Accent color |
| `tooltip-info` | Info/blue color |
| `tooltip-success` | Success/green color |
| `tooltip-warning` | Warning/amber color |
| `tooltip-error` | Error/red color |

---

# DATA INPUT

## Calendar
> Styled wrappers for third-party calendar libraries (Cally, Pikaday, React Day Picker).

| Class | Description |
|-------|-------------|
| `cally` | Styles for the Cally web component calendar |
| `pika-single` | Styles for Pikaday calendar input field |
| `react-day-picker` | Styles for the React Day Picker component |

---

## Checkbox
> Styled checkbox input with color and size variants.

| Class | Description |
|-------|-------------|
| `checkbox` | Core checkbox input component styling |
| `checkbox-primary` | Primary theme color |
| `checkbox-secondary` | Secondary theme color |
| `checkbox-accent` | Accent theme color |
| `checkbox-neutral` | Neutral theme color |
| `checkbox-success` | Success state color |
| `checkbox-warning` | Warning state color |
| `checkbox-info` | Info state color |
| `checkbox-error` | Error state color |
| `checkbox-xs` | Extra small size |
| `checkbox-sm` | Small size |
| `checkbox-md` | Medium size (default) |
| `checkbox-lg` | Large size |
| `checkbox-xl` | Extra large size |

---

## Fieldset
> Semantic container for grouping related form elements with a legend/title.

| Class | Description |
|-------|-------------|
| `fieldset` | Container grouping related form elements semantically |
| `fieldset-legend` | Styles the legend/title element within a fieldset |

---

## File Input
> Styled file upload input with color and size variants.

| Class | Description |
|-------|-------------|
| `file-input` | Base component class for `<input type="file">` styling |
| `file-input-ghost` | Applies a ghost/minimal style |
| `file-input-neutral` | Neutral color scheme |
| `file-input-primary` | Primary brand color |
| `file-input-secondary` | Secondary brand color |
| `file-input-accent` | Accent color |
| `file-input-info` | Info/blue color |
| `file-input-success` | Success/green color |
| `file-input-warning` | Warning color |
| `file-input-error` | Error/red color |
| `file-input-xs` | Extra small size |
| `file-input-sm` | Small size |
| `file-input-md` | Medium size (default) |
| `file-input-lg` | Large size |
| `file-input-xl` | Extra large size |

---

## Filter
> Group of radio/checkbox inputs that acts as a filter with a reset option.

| Class | Description |
|-------|-------------|
| `filter` | Main container wrapping radio/checkbox inputs for filter functionality |
| `filter-reset` | Alternative reset class for non-form implementations |

---

## Label
> Styled text label paired with form inputs, with floating label animation support.

| Class | Description |
|-------|-------------|
| `label` | Base component class for styling text next to inputs |
| `floating-label` | Parent container enabling animated floating label on focus |

---

## Radio
> Styled radio button input with color and size variants.

| Class | Description |
|-------|-------------|
| `radio` | Core styling for radio input elements |
| `radio-neutral` | Neutral color scheme |
| `radio-primary` | Primary brand color |
| `radio-secondary` | Secondary color |
| `radio-accent` | Accent color |
| `radio-success` | Success/positive color |
| `radio-warning` | Warning/caution color |
| `radio-info` | Informational color |
| `radio-error` | Error/danger color |
| `radio-xs` | Extra small size |
| `radio-sm` | Small size |
| `radio-md` | Medium size (default) |
| `radio-lg` | Large size |
| `radio-xl` | Extra large size |

---

## Range
> Styled range slider input with color and size variants plus CSS variable customization.

| Class | Description |
|-------|-------------|
| `range` | Core component class for `<input type="range">` |
| `range-neutral` | Neutral color scheme |
| `range-primary` | Primary theme color |
| `range-secondary` | Secondary theme color |
| `range-accent` | Accent color |
| `range-success` | Success/positive color |
| `range-warning` | Warning color |
| `range-info` | Informational color |
| `range-error` | Error/danger color |
| `range-xs` | Extra small size |
| `range-sm` | Small size |
| `range-md` | Medium size (default) |
| `range-lg` | Large size |
| `range-xl` | Extra large size |

> CSS variables: `--range-bg` (track background), `--range-thumb` (handle color), `--range-fill: 0` to disable fill.

---

## Rating
> Star (or custom shape) rating input built from radio buttons, with half-star support.

| Class | Description |
|-------|-------------|
| `rating` | Container for radio inputs creating the rating component |
| `rating-half` | Enables half-star ratings |
| `rating-hidden` | Hides the first radio input to allow clearing a rating |
| `rating-xs` | Extra small size |
| `rating-sm` | Small size |
| `rating-md` | Medium size (default) |
| `rating-lg` | Large size |
| `rating-xl` | Extra large size |
| `mask-star` | Star-shaped mask for standard ratings |
| `mask-star-2` | Alternative bold star shape |
| `mask-heart` | Heart-shaped mask for ratings |
| `mask-half-1` | Applies mask to the first half of an element |
| `mask-half-2` | Applies mask to the second half of an element |

---

## Select
> Styled `<select>` dropdown with ghost, color, and size variants.

| Class | Description |
|-------|-------------|
| `select` | Core styling for `<select>` element |
| `select-ghost` | Removes background for minimal appearance |
| `select-neutral` | Neutral color scheme |
| `select-primary` | Primary brand color |
| `select-secondary` | Secondary color accent |
| `select-accent` | Accent color |
| `select-info` | Informational blue tone |
| `select-success` | Success green tone |
| `select-warning` | Warning yellow/orange tone |
| `select-error` | Error red tone |
| `select-xs` | Extra small size |
| `select-sm` | Small size |
| `select-md` | Medium size (default) |
| `select-lg` | Large size |
| `select-xl` | Extra large size |

---

## Input (Text)
> Styled text input with ghost, color, and size variants, composable with other elements.

| Class | Description |
|-------|-------------|
| `input` | Core component class for `<input type="text">` or wrapper elements |
| `input-ghost` | Minimal ghost style with transparent background |
| `input-neutral` | Neutral color variant |
| `input-primary` | Primary brand color |
| `input-secondary` | Secondary color |
| `input-accent` | Accent color |
| `input-info` | Info state color |
| `input-success` | Success state color |
| `input-warning` | Warning state color |
| `input-error` | Error state color |
| `input-xs` | Extra small size |
| `input-sm` | Small size |
| `input-md` | Medium size (default) |
| `input-lg` | Large size |
| `input-xl` | Extra large size |

---

## Textarea
> Styled multi-line text input with ghost, color, and size variants.

| Class | Description |
|-------|-------------|
| `textarea` | Core component class for `<textarea>` element |
| `textarea-ghost` | Removes background for minimal appearance |
| `textarea-neutral` | Neutral color scheme |
| `textarea-primary` | Primary brand color |
| `textarea-secondary` | Secondary brand color |
| `textarea-accent` | Accent color |
| `textarea-info` | Info/blue color |
| `textarea-success` | Success/green color |
| `textarea-warning` | Warning/amber color |
| `textarea-error` | Error/red color |
| `textarea-xs` | Extra small size |
| `textarea-sm` | Small size |
| `textarea-md` | Medium size (default) |
| `textarea-lg` | Large size |
| `textarea-xl` | Extra large size |

---

## Toggle
> Checkbox styled as a switch/toggle button with color and size variants.

| Class | Description |
|-------|-------------|
| `toggle` | Main class for styling checkboxes as switch buttons |
| `toggle-primary` | Primary color theme |
| `toggle-secondary` | Secondary color theme |
| `toggle-accent` | Accent color theme |
| `toggle-neutral` | Neutral color theme |
| `toggle-success` | Success state color |
| `toggle-warning` | Warning state color |
| `toggle-info` | Informational state color |
| `toggle-error` | Error state color |
| `toggle-xs` | Extra small size |
| `toggle-sm` | Small size |
| `toggle-md` | Medium size (default) |
| `toggle-lg` | Large size |
| `toggle-xl` | Extra large size |

---

## Validator
> Adds automatic error/success styling to form inputs based on HTML5 validation attributes.

| Class | Description |
|-------|-------------|
| `validator` | Applies error or success styling based on native HTML5 validation |
| `validator-hint` | Displays hint text below invalid inputs; invisible when valid |

> Works with `required`, `pattern`, `minlength`, `maxlength`, `min`, `max`, and `type` HTML attributes.

---

# LAYOUT

## Divider
> A horizontal or vertical separator line with optional centered text and color variants.

| Class | Description |
|-------|-------------|
| `divider` | Base component class for creating separator lines |
| `divider-vertical` | Default vertical separator for stacked elements |
| `divider-horizontal` | Separator for horizontally adjacent elements |
| `divider-neutral` | Neutral color scheme |
| `divider-primary` | Primary theme color |
| `divider-secondary` | Secondary theme color |
| `divider-accent` | Accent color |
| `divider-success` | Success state color |
| `divider-warning` | Warning state color |
| `divider-info` | Informational color |
| `divider-error` | Error state color |
| `divider-start` | Positions divider text at the beginning edge |
| `divider-end` | Positions divider text at the trailing edge |

---

## Drawer
> Sidebar navigation panel that slides in from the side with overlay support.

| Class | Description |
|-------|-------------|
| `drawer` | Main wrapper establishing grid layout for sidebar and content |
| `drawer-toggle` | Hidden checkbox controlling drawer visibility state |
| `drawer-content` | Container for the primary page content |
| `drawer-side` | Wrapper for the sidebar section |
| `drawer-overlay` | Dark overlay; clicking it closes the drawer |
| `drawer-end` | Positions the drawer on the right side instead of left |
| `drawer-open` | Forces the drawer to remain visible regardless of checkbox state |
| `lg:drawer-open` | Makes the drawer always visible on large screens |

---

## Footer
> Page footer with support for columns, horizontal/vertical layout, and centering.

| Class | Description |
|-------|-------------|
| `footer` | Main container element for the footer |
| `footer-title` | Styles section headings within footer columns |
| `footer-horizontal` | Arranges footer columns side by side (default on sm+) |
| `footer-vertical` | Stacks footer columns vertically |
| `footer-center` | Centers all footer content horizontally and vertically |

---

## Hero
> Full-width section for prominent page headers with background images and overlay support.

| Class | Description |
|-------|-------------|
| `hero` | Main container for large hero sections |
| `hero-content` | Contains the text and elements within the hero |
| `hero-overlay` | Overlay covering background images to improve text readability |

---

## Indicator
> Positions a badge or status element on a corner of a sibling element.

| Class | Description |
|-------|-------------|
| `indicator` | Container establishing positioning context for indicator items |
| `indicator-item` | The element positioned on a corner of its sibling |
| `indicator-start` | Aligns indicator to the left edge |
| `indicator-center` | Aligns indicator to the horizontal center |
| `indicator-end` | Aligns indicator to the right edge (default) |
| `indicator-top` | Positions indicator at the top edge (default) |
| `indicator-middle` | Positions indicator at the vertical center |
| `indicator-bottom` | Positions indicator at the bottom edge |

---

## Join
> Groups multiple elements (buttons, inputs) together with shared border radius.

| Class | Description |
|-------|-------------|
| `join` | Main container grouping multiple items together |
| `join-item` | Individual item within the join container |
| `join-vertical` | Displays join items in a vertical/stacked layout |
| `join-horizontal` | Displays join items in a horizontal/inline layout (default) |

---

## Mask
> Clips element content into various shapes using CSS mask.

| Class | Description |
|-------|-------------|
| `mask` | Base class applying the mask component styling |
| `mask-squircle` | Smooth rounded-square (squircle) shape |
| `mask-heart` | Heart shape |
| `mask-hexagon` | Vertical hexagon shape |
| `mask-hexagon-2` | Horizontal hexagon shape |
| `mask-decagon` | Ten-sided polygon (decagon) |
| `mask-pentagon` | Five-sided polygon (pentagon) |
| `mask-diamond` | Diamond shape |
| `mask-square` | Square shape |
| `mask-circle` | Circular shape |
| `mask-star` | Standard star shape |
| `mask-star-2` | Bold/thick star shape |
| `mask-triangle` | Triangle pointing upward |
| `mask-triangle-2` | Triangle pointing downward |
| `mask-triangle-3` | Triangle pointing leftward |
| `mask-triangle-4` | Triangle pointing rightward |
| `mask-half-1` | Displays only the first half of the mask shape |
| `mask-half-2` | Displays only the second half of the mask shape |

---

## Stack
> Layers child elements on top of each other with configurable alignment.

| Class | Description |
|-------|-------------|
| `stack` | Primary class positioning child elements stacked on top of each other |
| `stack-top` | Aligns stacked children to the top edge |
| `stack-bottom` | Aligns stacked children to the bottom edge (default) |
| `stack-start` | Aligns stacked children to the start/left horizontally |
| `stack-end` | Aligns stacked children to the end/right horizontally |

---

# MOCKUP

## Mockup Browser
> A decorative box styled to resemble a browser window with toolbar and address bar.

| Class | Description |
|-------|-------------|
| `mockup-browser` | Primary container styled as a browser window frame |
| `mockup-browser-toolbar` | Toolbar section at the top containing the address bar area |

---

## Mockup Code
> A code block styled as a terminal/code editor with line prefixes and color highlights.

| Class | Description |
|-------|-------------|
| `mockup-code` | Main container styling a code block as an editor/terminal box |

> Use `data-prefix` HTML attribute on `<pre>` lines to add prefixes (e.g., `$`, `>`).

---

## Mockup Phone
> A decorative box styled to resemble a smartphone with camera notch and screen area.

| Class | Description |
|-------|-------------|
| `mockup-phone` | Main container styled as a smartphone frame |
| `mockup-phone-camera` | Renders the front-facing camera notch at the top |
| `mockup-phone-display` | Container for the phone screen content area |

---

## Mockup Window
> A decorative box styled to resemble a desktop OS window with a title bar.

| Class | Description |
|-------|-------------|
| `mockup-window` | Creates a box styled like an operating system window with title bar |

---

*65 components across 8 categories. Full interactive examples: https://daisyui.com/components/*
