"""
Kitty tab bar with centered tabs and minimal design
Features:
- Centered tabs with just index number and name
- No background colors on tabs
- Right-side status with date and time only
"""

import datetime
from kitty.boss import get_boss
from kitty.fast_data_types import Screen, add_timer, get_options
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    Formatter,
    TabBarData,
    as_rgb,
    draw_attributed_string,
)

timer_id = None


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    global timer_id

    # Set up timer for status updates (every 30 seconds)
    if timer_id is None:
        timer_id = add_timer(_redraw_tab_bar, 30.0, True)

    # Draw tabs centered
    _draw_centered_tabs(
        draw_data, screen, tab, before, max_title_length, index, is_last, extra_data
    )

    # Draw right status on the last tab
    if is_last:
        draw_right_status(draw_data, screen)

    return screen.cursor.x


def _draw_centered_tabs(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    """Draw tabs with no background, just text"""

    # Use default background for all tabs
    opts = get_options()
    default_bg = as_rgb(int(draw_data.default_bg))
    default_fg = as_rgb(int(draw_data.default_fg))

    # Set colors - no special background
    screen.cursor.bg = default_bg

    if tab.is_active:
        screen.cursor.fg = as_rgb(int(draw_data.active_fg))
        screen.cursor.bold = True
    else:
        screen.cursor.fg = default_fg
        screen.cursor.bold = False

    # Draw the tab content: "index  title"
    tab_text = f" {index}  {tab.title} "

    # Truncate if too long
    if len(tab_text) > max_title_length:
        tab_text = tab_text[: max_title_length - 1] + "…"

    screen.draw(tab_text)

    # Reset formatting
    screen.cursor.bold = False

    return screen.cursor.x


def draw_right_status(draw_data: DrawData, screen: Screen) -> None:
    """Draw date and time on the right side"""
    # Reset any formatting
    draw_attributed_string(Formatter.reset, screen)

    cells = create_cells()

    # Calculate padding
    right_status_length = sum(len(c) + 2 for c in cells)
    padding = screen.columns - screen.cursor.x - right_status_length

    if padding > 0:
        screen.draw(" " * padding)

    # Get colors
    opts = get_options()
    default_bg = as_rgb(int(draw_data.default_bg))
    default_fg = as_rgb(int(draw_data.default_fg))

    screen.cursor.bg = default_bg
    screen.cursor.fg = default_fg

    # Draw each cell
    for cell in cells:
        screen.draw(f" {cell} ")


def create_cells() -> list[str]:
    """Create the status cells - just date and time"""
    now = datetime.datetime.now()
    return [
        now.strftime("%D %d/%m/%y"),  # dd/mm/yy
        now.strftime("%H:%M"),  # "17:51"
    ]


def _redraw_tab_bar(timer_id) -> None:
    """Force redraw of the tab bar"""
    for tm in get_boss().all_tab_managers:
        tm.mark_tab_bar_dirty()
