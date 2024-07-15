#SingleInstance, Force
#NoTrayIcon
#Include <AuxLib>

    AuxLibLoad()

    SetRegView 64
    RegRead, DeveloperDir, HKCU\Software\Developer, DeveloperDir
    ProjectDir := GetProjectDir()

    if (A_Args.Length() > 0) {
        label := A_Args[1]
        if IsLabel(label) {
            Gosub %label%
        }
        ExitApp
    }

    ; Project Menu
    AddMenuItemEditor("ProjectMenu")
    AddMenu( "ProjectMenu" )
    AddMenu( "ProjectMenu", "&README.md...`tR", "OnReadme", BrowserPath )
    AddMenu( "ProjectMenu" )
    AddMenu( "ProjectMenu", "&Sync with Upstream`tS", "OnSyncWithUpstream", ConEmuPath )
    AddMenu( "ProjectMenu", "&Praison AI...`tP", "OnPraisonAI", ResDir "github.ico" )
    AddMenu( "ProjectMenu" )
    AddMenuItemEditProjectMenu("ProjectMenu")
    ShowMenu( "ProjectMenu" )
    ExitApp
return ; end of script's auto-execute section

MenuHandler:
    MsgBox % "MenuHandler was called."
return

OnSyncWithUpstream:
    ProjectDir := GetProjectDir()
    SyncWithUpstream(ProjectDir, "https://github.com/MervinPraison/PraisonAI.git")
return

OnPraisonAI:
    ProjectDir := GetProjectDir()
    SplitPath, A_LineFile,, ProjectDir
    SplitPath, ProjectDir,, ProjectDir

    ShiftPressed := GetKeyState("Shift","P")
    BatchScript =
    (

        cd "%ProjectDir%" || goto :error
        if "!errorlevel!" equ "0" `(
            set should_install=%ShiftPressed%
            call e exist >nul 2>&1
            if "!errorlevel!" equ "1" set should_install=1
            if "!should_install!" equ "1" `(
                call e remove
                call e || goto :error
                cd "%ProjectDir%" || goto :error
                pip install -e . || goto :error
                call conda.bat deactivate
            `)
            call e || goto :error
            praisonai code
        `)
    )
    Options := { Visible: "ConEmu", Pause: true, Admin: true }
    RunBat( Options, StripBat(BatchScript) ) 
return
