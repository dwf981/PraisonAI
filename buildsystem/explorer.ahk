#SingleInstance Off
#NoTrayIcon
#Include <AuxLib>

    AuxLibLoad( "default" )

    Cli_Dispatch()

    ; Project Menu
    AddMenuItemEditor("ProjectMenu")
    AddMenu( "ProjectMenu" )
    AddMenu( "ProjectMenu", "&README.md...`tR", "OnReadme", BrowserPath )
    AddMenu( "ProjectMenu" )
    AddMenu( "ProjectMenu", "&Sync with Upstream`tS", "OnSyncWithUpstream", ConEmuPath )
    AddMenu( "ProjectMenu", "&Praison AI...`tP", "OnPraisonAI", ResDir "github.ico" )
    AddMenu( "ProjectMenu", "En&vironment Shell...`tV", "OnEnvironmentShell", ConEmuPath )
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
    Subcommand := GetKeyState("Shift","P") ? "chat" : "code"
    ProjectDir := GetProjectDir()
    SplitPath, A_LineFile,, PraisonDir
    SplitPath, PraisonDir,, PraisonDir

    BatchScript =
    (

        call e exist env PraisonAI >nul 2>&1
        if "!errorlevel!" equ "1" `(
            cd "%PraisonDir%" || goto :error
            call e env PraisonAI || goto :error
            pip install -e .[code,chat] || goto :error
            call conda.bat deactivate
        `)
        cd "%ProjectDir%" || goto :error
        call e env PraisonAI || goto :error
        echo Running !yellow!praisonai %Subcommand%!nc! in !green!%ProjectDir%!nc! ...
        echo.
        praisonai %Subcommand%
    )
    Options := { Visible: "ConEmu", Pause: true, Admin: true, Colors: true }
    RunBat( Options, StripBat(BatchScript) )
return

OnEnvironmentShell:
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
                pip install -e .[code,chat] || goto :error
                call conda.bat deactivate
            `)
            call e || goto :error
            cmd
        `)
    )
    Options := { Visible: "ConEmu", Pause: true, Admin: true }
    RunBat( Options, StripBat(BatchScript) )
return
