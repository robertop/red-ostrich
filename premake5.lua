-------------------------------------------------------------------
-- Copyright (c) Roberto Perpuly. All rights reserved.
-- Licensed under the MIT License. See License in the project root for details.
-------------------------------------------------------------------

-- --
-- Cross-platform & cross build-toll definition of a project. This definition is
-- used to create makefiles, visual studio solutions, and project files for other
-- IDEs. This file is used by premake. You need to install premake and then run
-- premake on the directory that contains this file.
-- --

includes = os.matchfiles("premake/*.lua")
for key, scriptFile in ipairs(includes) do
    dofile(scriptFile)
end

