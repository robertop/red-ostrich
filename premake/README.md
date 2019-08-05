Build System
========

This project uses [premake](https://premake.github.io/) for its build system. We describe
the project in a build-system agnostic way and premake creates XCode, Make files, or Visual
Studio solution files.

Reasons why this project uses premake
========
1. This project is cross-platform. Premake saves us time in keeping various xcode vs
makefiles vs solution files in sync.
2. We can define custom tasks (premake calls them actions) in a scripting language (lua).
   With lua we can make calls to external programs; we can basically do anything that
   we require. We don't need python, ruby, javascript or other languages.
3. There is no standard build system for C++ projects that can also handle fetching
   and integrating dependencies in a cross-platform way.

To create a custom task
========
1. Create a file in the `premake` directory.
2. Use the premake `newaction` syntax to make a task.

A custom file will look like this

```
function customAction()
  -- code that does the custom action
end

newaction {
    trigger = "custom",
    description = "My custom action",
    execute = customAction
}

```

It is then available via `premake5 custom`

Build system organization
=========
* Custom actions go in `premake/action_*.lua` files
* Functions that are shared among actions are places in `premake/functions_*.lua` files.
