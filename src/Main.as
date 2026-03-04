const string  pluginColor = "\\$393";
const string  pluginIcon  = Icons::Bars;
Meta::Plugin@ pluginMeta  = Meta::ExecutingPlugin();
const string  pluginTitle = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;

float g_dt = 0.0f;

void Render() {
    if (!S_Enabled) {
        return;
    }

    CGameCtnApp@ App = GetApp();
    if (true
        and App.CurrentPlayground !is null
        and App.CurrentPlayground.UIConfigs.Length > 0
        and App.CurrentPlayground.UIConfigs[0].UISequence == CGamePlaygroundUIConfig::EUISequence::Intro
    ) {
        return;
    }

    if (App.GameScene !is null) {
        RenderProtractor();
    }
}

void RenderMenu() {
    if (UI::MenuItem(pluginTitle, "", S_Enabled)) {
        S_Enabled = !S_Enabled;
    }
}

void Update(float dt) {
    g_dt = dt;
}
