-------------------------------------------------------------------
-- Copyright (c) Roberto Perpuly. All rights reserved.
-- Licensed under the MIT License. See License in the project root for details.
-------------------------------------------------------------------

--
-- Prepare the scintilla library
--
-- On MacOSX we use carthage to compile it AND to integrate it into
-- XCode.
--
function FetchScintilla()
    if os.ishost 'macosx' then
        local failMsg = "You need carthage in order to setup the dev environment.\n" ..
            "You can install carthage via brew\n\n" ..
            "brew install carthage\n"
        ProgramExistence(CARTHAGE, "version", failMsg);
        local cmd = CARTHAGE .. " bootstrap scintilla"
        BatchExecute("mac", {
            cmd
        })
    end
end

function CompileScintilla()
    if os.ishost "macosx" then
        FetchScintilla()
    else
        print "Building Scintilla on this operating system is no supported at this time.\n"
    end
end
