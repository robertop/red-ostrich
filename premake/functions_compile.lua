-------------------------------------------------------------------
-- Copyright (c) Roberto Perpuly. All rights reserved.
-- Licensed under the MIT License. See License in the project root for details.
-------------------------------------------------------------------

-- Compile the project. Compiling may use operating system specific build
-- tools.

function compile()
    if os.ishost('macosx') then
        compileMacXcode('debug', false)
    end
end

function compileMacXcode(config)
    -- XCode configurations are in title case
    if config == "debug" then
        config = "Debug"
    end
    if config == "release" then
        config = "Release"
    end

    BatchExecute('mac', {
        string.format('%s -quiet -target %s -configuration %s -project %s build',
            XCODE_BUILD, "mac-editor", config, "mac-editor.xcodeproj")
    })
end

newaction {
    trigger = "compile",
    description = "Build the project from the command line.",
    execute = compile
}
