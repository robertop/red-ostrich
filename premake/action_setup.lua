-------------------------------------------------------------------
-- Copyright (c) Roberto Perpuly. All rights reserved.
-- Licensed under the MIT License. See License in the project root for details.
-------------------------------------------------------------------

--
-- this function will setup the development environment by running all actions
-- for the dependencies.  After
-- this function runs, the project will be able to be compiled successfully.
--
-- This function will make sure that necessary programs
-- are present.
--
-- This function only needs to be run once; when a developer wants to
-- compile the project for the first time on a machine.
--
-- Philosophies:
-- 1. fail fast: check for prerequisites upfront and before starting to
--    fetch / compile. This way users can see and fix missing prerequisites
--    right away.
-- 2. prefer native package managers for fetching / using dependencies. For example,
--    use the boost version that is packaged rather than the latest version. This
--    reduces time to setup by not having to compile dependencies. Also makes
--    final packages smaller. The trade-off is that the project must support various
--    versions of the same library.
--    Package managers:
--    Linux: apt, dnf,
--    Mac OS X: brew
--    MSW: nuget
-- 3. This process is self-healing; it will check for dependencies and not install
--    them if they are already installed.
--
function setup()
    if os.ishost 'macosx' then
        local failMsg = "You need carthage in order to setup the dev environment.\n" ..
            "You can install carthage via brew\n\n" ..
            "brew install carthage\n"
        ProgramExistence(CARTHAGE, "version", failMsg);
    end

    -- download or compile these dependencies

    if os.ishost("macosx") then
        CompileScintilla();
    end

    print "SUCCESS! All dependencies are met. Next step is to build in your environment.";
    if os.ishost "macosx" then
        print "open mac/mac-editor.xcodeproj and run the project. \n"
    end
end

newaction {
    trigger = "setup",
    description = "Initial setup of the development environment. Run this first.",
    execute = setup
}
