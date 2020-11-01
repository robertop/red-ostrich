-------------------------------------------------------------------
-- Copyright (c) Roberto Perpuly. All rights reserved.
-- Licensed under the MIT License. See License in the project root for details.
-------------------------------------------------------------------

--
-- This action performs source code style checks for this project's source code by using
-- Google's C++ source code style linter.  This action should
-- be run before every push to the central repository.
--
function lint()
    if os.ishost "windows" then
        print "lint only works on linux or Mac OS X systems.\n";
        os.exit(1);
    elseif os.ishost "linux" or os.ishost "macosx" then
        local failMsg = "The lint action requires that clang-format be installed."
        ProgramExistence(CLANG_FORMAT, "-version", failMsg)

        local successLintObjectiveC = lintObjectiveC()

        -- now check the lua source code
        dofile('premake/blitwizard/checkstyle_patched.lua')
        local successLuaLint = lintlua()

        if not successLintObjectiveC then
            print("Objective C check completed with failures.")
            os.exit(1);
        end

        if not successLuaLint then
            print("Lua check completed with failures.")
            os.exit(1);
        end
    else
        print "Lint is not supported on this operating system.\n"
    end

    os.exit(0)
end

function lintObjectiveC()
    -- check objective C files, this is a bit involved as we use clang-format
    -- and clang-format is not a checker it just wants to make changes. So, we
    -- make a checker by running each file and comparing the file against the
    -- output of clang-format
    print("Checking Objective-C files ...")
    local successObjCLint = true
    local objectiveCfiles = os.matchfiles('mac/mac-editor/**.m')
    for i, file in ipairs(objectiveCfiles) do
        local exitCode, result = lintObjectiveCFile(file)
        if exitCode > 0 then
            successObjCLint = false
            print("[ERROR] Style error in " .. file)
            print(result)
        end
    end
    objectiveCfiles = os.matchfiles('mac/mac-editor/**.h')
    for i, file in ipairs(objectiveCfiles) do
        local exitCode, result = lintObjectiveCFile(file)
        if exitCode > 0 then
            successObjCLint = false
            print("[ERROR] Style error in " .. file)
            print(result)
        end
    end

    return successObjCLint;
end

function lintObjectiveCFile(file)
    local tmpFile = StringTrim(ExecOutput(string.format("dirname '%s' | awk '{ print $1 \"/formatted.XXX\"}' | xargs mktemp", file)))
    local configFile = NormalizePath("mac/.clang-format")
    local cmd = string.format("%s -style=file %s > %s", CLANG_FORMAT, file, tmpFile)
    if not os.execute(cmd) then
        print("error generating diff with " .. cmd)
    end
    cmd = string.format("diff -u %s %s", file, tmpFile)
    local result, exitCode = os.outputof(cmd)
    -- result is null on error, capture it again
    result = ExecOutput(cmd);
    os.execute("rm " .. tmpFile)
    return exitCode, result;
end

-- Returns true on success (no lint errors),
-- false when at least one lua file has a style error.
function lintlua()
    print("Checking lua files ...")
    local i = 1
    local files = os.matchfiles('premake/*.lua')
    while i <= #files do
        checkfile(files[i])
        i = i + 1
    end
    checkfile('premake5.lua')
    if styleerror then
        return false
    end
    return true
end

newaction {
    trigger = "lint",
    description = "Perform code style checks against the current working copy of the code.",
    execute = lint
}

newoption {
    trigger = "lint-all",
    description = "Lint all files, not only files that have changed from origin/master."
}
