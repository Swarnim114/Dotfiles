#!/bin/bash

COLORS_FILE="$HOME/.config/noctalia/colors.json"
THEME_DIR="$HOME/.config/spicetify/Themes/Noctalia"

if [[ ! -f "$COLORS_FILE" ]]; then
    echo "Error: $COLORS_FILE does not exist."
    exit 1
fi

mkdir -p "$THEME_DIR"

get_color() {
    local key=$1
    local default_key=$2
    local color
    color=$(jq -r ".. | .$key? | select(type == \"string\")" "$COLORS_FILE" | head -n 1 | tr -d '#')
    if [[ -z "$color" && -n "$default_key" ]]; then
        color=$(jq -r ".. | .$default_key? | select(type == \"string\")" "$COLORS_FILE" | head -n 1 | tr -d '#')
    fi
    if [[ -z "$color" ]]; then color="e9f1da"; fi # fallback
    echo "$color"
}

mSurface=$(get_color "mSurface")
mOnSurface=$(get_color "mOnSurface")
mSurfaceVariant=$(get_color "mSurfaceVariant" "mSurface")
mOnSurfaceVariant=$(get_color "mOnSurfaceVariant" "mOnSurface")
mPrimary=$(get_color "mPrimary")
mOnPrimary=$(get_color "mOnPrimary" "mOnSurface")
mSecondary=$(get_color "mSecondary" "mPrimary")
mOutline=$(get_color "mOutline" "mOnSurfaceVariant")
mError=$(get_color "mError")
mShadow=$(get_color "mShadow" "mSurfaceVariant")

cat <<INI_EOF > "$THEME_DIR/color.ini"
[Noctalia]
text               = ${mOnSurface}
subtext            = ${mOnSurfaceVariant}
main               = ${mSurface}
sidebar            = ${mSurfaceVariant}
player             = ${mSurfaceVariant}
card               = ${mSurfaceVariant}
shadow             = ${mShadow}
selected-row       = ${mOutline}
button             = ${mPrimary}
button-active      = ${mSecondary}
button-disabled    = ${mOutline}
tab-active         = ${mSecondary}
notification       = ${mSecondary}
notification-error = ${mError}
misc               = ${mSurfaceVariant}
INI_EOF

cat <<CSS_EOF > "$THEME_DIR/user.css"
/* Inject CSS variables overriding Spotify's modern internal variables */
:root, .Root__top-container, #main, .Root__main-view, .main-view-container, [data-theme], body {
    --background-base: #${mSurface} !important;
    --background-highlight: #${mSurfaceVariant} !important;
    --background-press: #${mSurfaceVariant} !important;
    --background-elevated-base: #${mSurfaceVariant} !important;
    --background-elevated-highlight: #${mOutline} !important;
    --background-elevated-press: #${mOutline} !important;
    --background-tinted-base: #${mSurfaceVariant} !important;
    --background-tinted-highlight: #${mOutline} !important;
    --background-tinted-press: #${mOutline} !important;
    
    --text-base: #${mOnSurface} !important;
    --text-subdued: #${mOnSurfaceVariant} !important;
    --text-bright: #${mOnSurface} !important;
    --text-negative: #${mError} !important;
    --text-warning: #${mError} !important;
    
    --essential-base: #${mPrimary} !important;
    --essential-subdued: #${mOutline} !important;
    --essential-bright: #${mSecondary} !important;
    --essential-warning: #${mError} !important;
}

/* Fix muddy gradients that extract colors from covers */
.main-home-homeHeader,
.main-entityHeader-backgroundColor,
.main-entityHeader-overlay,
.main-entityHeader-background,
.main-entityHeader-withBackgroundImage,
.main-actionBarBackground-background {
    background: transparent !important;
    background-image: none !important;
    box-shadow: none !important;
}

/* Specific component fixes */
/* Artist cards and standard cards */
.main-card-card, 
.artist-artistAbout-container, 
.main-trackCreditsModal-container,
.main-aboutRecsModal-container,
.search-searchCategory-SearchCategory {
    background-color: var(--background-elevated-base) !important;
    color: var(--text-base) !important;
}

/* Make sure PRIMARY big play buttons are the main focus color, 
   but leave inline/recently played small list buttons alone */
.main-playButton-Primary {
    background-color: var(--essential-base) !important;
    color: #${mOnPrimary} !important;
}
/* Ensure the inner SVG doesn't grab a solid background block */
.main-playButton-Primary svg, .main-playButton-PlayButton svg {
    background-color: transparent !important;
}

/* Force recently played / inline list play buttons to inherit their natural transparent backgrounds */
.main-trackList-rowPlayPauseButton,
.main-yourLibraryX-listRow .main-playButton-PlayButton,
li .main-playButton-PlayButton {
    background-color: transparent !important;
    color: var(--text-base) !important;
}

/* Category Filter Chips */
.ChipInner__ChipInnerComponent-sc-1ly6j4j-0 {
    background-color: var(--background-highlight) !important;
    color: var(--text-base) !important;
}
.ChipInner__ChipInnerComponent-sc-1ly6j4j-0[aria-checked="true"] {
    background-color: var(--essential-base) !important;
    color: #${mOnPrimary} !important;
}

/* Global Nav bar components */
.main-globalNav-historyButtons .main-globalNav-icon,
.main-globalNav-searchContainer input {
    background-color: var(--background-highlight) !important;
    color: var(--text-base) !important;
}
/* Ensure search icon resolves properly inside the input wrapper */
.main-globalNav-searchContainer .main-globalNav-searchIcon {
    color: var(--text-base) !important;
}
CSS_EOF

