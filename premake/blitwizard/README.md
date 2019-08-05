checkstyle.lua was copied from the repo located at

https://github.com/JonasT/Blitwizard/

checkstyle.lua is a syntax checker for lua source code. It has a few
modifications:

- Added string.starts(), string.ends()
- removed the run() function
- made the default language checked to be lua
- fix nil variable accesses

The patch
=========


205c205
<             if stringend > 1 then
---
>             if stringend and stringend > 1 then
267c267
<         local language = "c"
---
>         local language = "lua"
403,414c403,404
< function run()
<     -- Run the style checker
<     local i = 1
<     while i <= #args do
<         checkfile(args[i])
<         i = i + 1
<     end
<     if styleerror then
<         os.exit(1)
<     else
<         os.exit(0)
<     end
---
> function string.starts(String,Start)
>    return string.sub(String,1,string.len(Start))==Start
417c407,409
< return run()
---
> function string.ends(String,End)
>    return End=='' or string.sub(String,-string.len(End))==End
> end