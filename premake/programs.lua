-------------------------------------------------------------------
-- Copyright (c) Roberto Perpuly. All rights reserved.
-- Licensed under the MIT License. See License in the project root for details.
-------------------------------------------------------------------

--
-- Below are constants for the various external binaries used by the build
-- system. Each location has a default but it can be modified via environment
-- variables in case some programs are installed in non-standard locations.

function programVariable(programName, programEnvironment, defaultPath)
    local name = os.getenv(programEnvironment)
    if (not name) then
        name = defaultPath;
        if _OPTIONS['verbose'] then
            print(string.format("Using default location of %s for %s", defaultPath, programName))
        end
    end
    return name
end

-- location of clang-format, used for style checking of objective C
-- source code.
CLANG_FORMAT = programVariable('CLANG_FORMAT', 'T4P_CLANG_FORMAT', 'clang-format')

-- location of carthage, a package manager for mac apps.
CARTHAGE = programVariable('CARTHAGE', 'T4P_CARTHAGE', 'carthage')

-- location of XcodeBuild, used to compile Mac apps.
XCODE_BUILD = programVariable('XCODE_BUILD', 'T4P_XCODE_BUILD', 'xcodebuild')
