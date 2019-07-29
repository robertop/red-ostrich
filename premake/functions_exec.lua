-------------------------------------------------------------------
-- Copyright (c) Roberto Perpuly. All rights reserved.
-- Licensed under the MIT License. See License in the project root for details.
-------------------------------------------------------------------

--
-- Checks that a program exists in the system by taking the binary
-- and the arg and executing it.  If the system call fails,
-- then the program does not exist, and the script ends.
-- most of the time, the arg will be '--version' as this
-- is the easiest way to check for program existence.
--
-- @param pathsToCheck a table of strings or a single string
--
function ProgramExistence(prog, arg, extraMessage)
    local cmdString = string.format("\"%s\" %s", prog, arg)
    if prog[0] == '"' then
        -- prog is already quoted
        cmdString = string.format('%s %s', prog, arg)
    end
    if not os.execute(cmdString) then
        print (prog .. " not found. " .. extraMessage)
        print "Program will now exit"
        os.exit(1)
    end
end

--
-- execute a table of commands
-- if a single command fails then the program will exit
--
-- @param basedir the directory where the commands will be executed from
-- @param cmds the list of commands
--
function BatchExecute(basedir, cmds, errorMessage)
    if #cmds then
        local cmdString = "cd " .. basedir .. " && ";
        for key, cmd in ipairs(cmds) do
            cmdString = cmdString .. cmd
            if next(cmds, key)  then
                cmdString = cmdString .. " && ";
            end
        end
        if #cmdString then
            print(cmdString)
            local ret = os.execute(cmdString)
            if not ret then
                if errorMessage then
                    print(errorMessage)
                end
                print "Command Failed"
                print(cmdString)
                print "Program will now exit"
                os.exit(1)
            end
        end
    end
end

-- executes the given command and returns the output
-- of the command.  Only returns stdout
-- this will return the entire output; it will most
-- likely need to be trimmed to remove unexpected
-- new lines
function ExecOutput(cmd)
    local cmdStream = io.popen(cmd)
    local cmdOutput = cmdStream:read("*a")
    cmdStream:close()
    return cmdOutput
end
