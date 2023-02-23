void RenderMenu()
{
    if (UI::MenuItem((g_visible ? "\\$393" : "\\$999") + Icons::Bars + "\\$z GigaChad Protractor", '', g_visible)) {
        g_visible = !g_visible;
    }
}