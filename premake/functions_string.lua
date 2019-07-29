-------------------------------------------------------------------
-- Copyright (c) Roberto Perpuly. All rights reserved.
-- Licensed under the MIT License. See License in the project root for details.
-------------------------------------------------------------------

-- trim whitespace from both ends of string
function StringTrim(s)
    return s:find'^%s*$' and '' or s:match'^%s*(.*%S)'
end

-- returns a table that has 1 item per each line of the
-- given string
function StringSplitLines(s)
    return StringSplitBy(s, "\n")
end

-- returns a table that has 1 item per each word of the
-- given string
function StringSplitColumns(s)
    return StringSplitBy(s, " ")
end

-- tokenizes a string by delimiter and returns
-- a table for items. No trimming or collapsing
-- of empty values is done
function StringSplitBy(s, delim)
    local t = {}
    local i = 0
    local next
    while true do
        next = string.find(s, delim, i)    -- find 'next' newline
        if next == nil then
            table.insert(t, string.sub(s, i))
            break
        end
        table.insert(t, string.sub(s, i, next))
        i = next + 1
    end
    return t
end
