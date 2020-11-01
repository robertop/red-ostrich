--------------------------------------------------------------------
-- Copyright (c) Roberto Perpuly. All rights reserved.
-- Licensed under the MIT License. See License in the project root for details.
--------------------------------------------------------------------

--
-- Print out a list of Mac packages needed to compile this project. The
-- action needs to be given the name of the system which packages are
-- needed for. Example:
--
--    premake mac-packages
--
function macosxPackages()
    -- packages for homebrew
    -- See https://brew.sh/
    local pkgs = {
        "carthage"
    }
    if os.getenv("CI") then
        table.insert(pkgs, "clang-format")
    end
    print(table.concat(pkgs, ' '))
end

newaction {
    trigger = "mac-packages",
    description = "List the brew packages required to compile this project.",
    execute = macosxPackages
}
