-------------------------------------------------------------------
-- Copyright (c) Roberto Perpuly. All rights reserved.
-- Licensed under the MIT License. See License in the project root for details.
-------------------------------------------------------------------

-- takes a path relative to the project root and returns an absolute path that
-- this function will also enclose the path in quotes; allowing file paths with spaces to be used.
-- main purpose of this function is to generate paths that can be embedded into strings that consist
-- of system commands.
-- be careful, the result of this function is NOT suitable for file functions
-- ie. os.isfile() since the result is already enclosed in quotes!
function NormalizePath(filepath)
    if not path.isabsolute(filepath) then
        filepath = os.getcwd() .. "/" .. filepath
    end
    local doQuote = string.find(filepath, " ")
    if os.ishost "windows" then

        -- Windows XP doesn't like forward slashes
        filepath = string.gsub(filepath, "/", "\\");
    end
    if doQuote then
        filepath = "\"" .. filepath .. "\"";
    end

    return filepath
end

--
-- takes a path relative to the project root and checks that it exists in the file system. if
-- the file does not exist the program will exit.
--
-- @param pathsToCheck a table of strings or a single string
--
function PathExistence(pathsToCheck, extraMessage)
    local paths = {}
    if 'string' == type(pathsToCheck) then
        table.insert(paths, pathsToCheck)
    elseif 'table' == type(pathsToCheck) then
        for key, value in pairs(pathsToCheck) do
            table.insert(paths, value)
        end
    end
    for key, value in pairs(paths) do
        if not os.isfile(value) then
            print("Required file not found: " .. value)
            print(extraMessage)
            print "Program will now exit"
            os.exit(1)
        end
    end
end
