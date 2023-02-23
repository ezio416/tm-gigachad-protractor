void RenderMenu()
{
    if (UI::MenuItem(Icons::Bars + " GigaChad Protractor", '', g_visible)) {
        g_visible = !g_visible;
    }
}