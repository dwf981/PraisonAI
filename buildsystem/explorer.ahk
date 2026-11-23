#Requires AutoHotkey v2.0
#SingleInstance Off
#Warn All, OutputDebug

#Include <Explorer>

ProjectMenu() {
    items := ProjectMenu_Editor(false)
    items.Push("-", ProjectMenu_Readme(), "-")
    items.Push({ text: "&Sync with Upstream`tS", id: "OnSyncWithUpstream", run: OnSyncWithUpstream, icon: "@ConEmuPath" })
    items.Push({ text: "&Praison AI...`tP", id: "OnPraisonAI", run: OnPraisonAI, icon: "github.ico" })
    items.Push({ text: "En&vironment Shell...`tV", id: "OnEnvironmentShell", run: OnEnvironmentShell, icon: "@ConEmuPath" })
    items.Push("-")
    items.Push(ProjectMenu_EditMenu()*)
    return items
}

; This script lives in <repo>\buildsystem.
ScriptRepo() => RegExReplace(A_ScriptDir, "\\[^\\]+$")

OnSyncWithUpstream() => SyncWithUpstream(Explorer2_ProjectDir(), "https://github.com/MervinPraison/PraisonAI.git")

; Runs `praisonai code` (Shift: `praisonai chat`) in the project, from the PraisonAI conda environment (created on first use).
OnPraisonAI() {
    Run_Bat({ Visible: "ConEmu", Pause: true, Admin: true, Colors: true, Vars: { PraisonDir: ScriptRepo(), ProjectDir: Explorer2_ProjectDir(), Subcommand: Cli_Shift() ? "chat" : "code" } }, "
(
call e exist env PraisonAI >nul 2>&1
if "!errorlevel!" equ "1" (
    cd "!PraisonDir!" || goto :error
    call e env PraisonAI || goto :error
    pip install -e .[code,chat] || goto :error
    call conda.bat deactivate
`)
cd "!ProjectDir!" || goto :error
call e env PraisonAI || goto :error
echo Running !yellow!praisonai !Subcommand!!nc! in !green!!ProjectDir!!nc! ...
echo.
praisonai !Subcommand!
)")
}

; A cmd shell in the PraisonAI conda environment (Shift: create it again).
OnEnvironmentShell() {
    Run_Bat({ Visible: "ConEmu", Pause: true, Admin: true, Vars: { ProjectDir: ScriptRepo(), Reinstall: Cli_Shift() ? "1" : "0" } }, "
(
cd "!ProjectDir!" || goto :error
if "!errorlevel!" equ "0" (
    set should_install=!Reinstall!
    call e exist >nul 2>&1
    if "!errorlevel!" equ "1" set should_install=1
    if "!should_install!" equ "1" (
        call e remove
        call e || goto :error
        pip install -e .[code,chat] || goto :error
        call conda.bat deactivate
    `)
    call e || goto :error
    cmd
`)
)")
}

Explorer2_Main(ProjectMenu)
