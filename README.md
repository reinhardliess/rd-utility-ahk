# Class rd_Utility

## Installation

In a terminal or command line, navigate to your project folder:

```bash
npm install rd-utility-ahk
```

In your code include the following:

```autohotkey
#Include, %A_ScriptDir%\node_modules\rd-regexp-ahk\rd_RegExp.ahk
#Include, %A_ScriptDir%\node_modules\rd-utility-ahk\rd_Utility.ahk

U := new rd_Utility()
```

## Description

`rd_Utility` is a utility class providing string, file and miscellaneous methods for Autohotkey.

All methods have function comments and if you're looking for examples check out the [tests](https://github.com/reinhardliess/rd-utility-ahk/blob/main/tests/all-tests.ahk).

If you use the VS Code [AutoHotkey Plus Plus](https://marketplace.visualstudio.com/items?itemName=mark-wiemer.vscode-autohotkey-plus-plus) extension, you might also want to check out _Peak Definition_ (`Alt+F12`) or _Go To Definition_ (`F12`).

These classes will throw an exception in case of a serious error by default which works well in combination with a [global error handler](https://www.autohotkey.com/docs/commands/OnError.htm). This behavior can be changed by setting `rd_Utility.throwExceptions := false`.

## Methods

### String Methods

| Method          | Description                                                                                         |
| --------------- | --------------------------------------------------------------------------------------------------- |
| convertToWrap   | Converts formatted paragraphs with (CR)LF to wrap                                                   |
| uriEncode       | Uri encode (JavaScript like)                                                                        |
| uriDecode       | Uri decode (JavaScript like)                                                                        |
| putVar          | Copies string to memory address, UTF-16 compatible                                                  |
| expandEnvVars   | Expands all environment variables stored in string                                                  |
| expandAhkVars   | Expands all [A\_ variables](https://www.autohotkey.com/docs/Variables.htm#BuiltIn) stored in string |
| expandVariables | Expands ${varname} variables in string                                                              |
| splitPath       | Splits path (Windows, URI) to object                                                                |
| buildFileName   | Change properties in path name (Windows, URI)                                                       |
| formatDateTime  | Transforms a time stamp into a specified date/time format                                           |

### String Methods With Better Unicode Support

These string methods are experimental and handle Unicode surrogate pairs better than their corresponding Autohotkey functions:

This comes with a speed penalty though, see a benchmark [here](./tests/bench-string-methods.ahk).

| Method     | Description                                                                      |
| ---------- | -------------------------------------------------------------------------------- |
| strLength  | Returns string length, Handles Unicode surrogate pairs better than `Strlen`      |
| strToArray | Converts string to array, handles Unicode surrogate pairs better than `StrSplit` |
| substring  | Retrieves part of string, handles Unicode surrogate pairs better than `Substr`   |

### File Methods

| Method           | Description                                                       |
| ---------------- | ----------------------------------------------------------------- |
| fileRead         | Read contents of text file into variable                          |
| fileWrite        | Writes string to file (overwrites existing, preserves hard links) |
| fileAppend       | Appends string to file                                            |
| fileTouch        | Creates empty file or updates modification date                   |
| createUniqueFile | Creates empty file with unique name                               |
| getFullPathName  | Retrieves full path name via Windows API                          |

### Misc Methods

| Method              | Description                                                                       |
| ------------------- | --------------------------------------------------------------------------------- |
| parseInt            | Converts string to integer                                                        |
| getWindowsErrorText | Retrieves Windows error message text for error number (`A_LastError`)             |
| defaultTo           | Checks value to determine whether a default value should be returned in its place |
