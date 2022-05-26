/*
  * Utility Class
  * Copyright(c) 2021-2022 Reinhard Liess
  * MIT Licensed
*/

class rd_Utility
{
  ; -- class variables --

  ; Throw exceptions by default
  static throwExceptions := true

  static ERR_FILEOPEN  := "Error while opening file '{1}'."
  static ERR_FILEREAD  := "Error while reading file '{1}'."
  static ERR_FILEWRITE := "Error while writing file '{1}'."

  ; --- instance variables ---

  ; constructor
  __New() {
  }

  ; -- string methods --

  /**
  * Converts formatted paragraphs with CRLF to wrap
  * Removes hyphens, and additional spaces, leaves paragraphs intact
  * @param {string} text - text to process
  * @returns {string} converted text
  */
  convertToWrap(text) {
    ; remove hyphens
    temp := StrReplace(text, "-`r`n")

    ; replace single CRLF with space but leave paragraphs intact
    buffer := RegExReplace(temp, "(\S[^\S\r\n]*)\r?\n([^\S\r\n]*\S)", "$1 $2")
    ; remove unnecessary spaces
    return Trim(RegExReplace(buffer, "  +", " "))
  }

  /**
  * Uri encode (JavaScript like)
  * NB: ahk files must be saved as UTF-8 with BOM
  * adapted from: https://autohotkey.com/board/topic/75390-ahk-l-Unicode-uri-encode-url-encode-function/
  * @param {string} URI - uniform resource identifier
  * @param {string} [Enc="UTF-8"] - file encoding
  * @returns {string} encoded URI
  */
  uriEncode(Uri, Enc := "UTF-8") {
    Res := ""
    this.putVar(Uri, Var, Enc)
    Loop {
      Code := NumGet(Var, A_Index - 1, "UChar")
      If (!Code) {
        Break
      }
      If (Code >= 0x30 && Code <= 0x39   ; 0-9
        || Code >= 0x41 && Code <= 0x5A  ; A-Z
        || Code >= 0x61 && Code <= 0x7A) ; a-z
        Res .= Chr(Code)
      Else
        Res .= "%" Substr(Format("{1:#X}", Code + 0x100), -1)
    }
    Return, Res
  }

  /**
  * Uri decode (JavaScript like)
  * NB: ahk files must be saved as UTF-8 with BOM
  * adapted from: https://autohotkey.com/board/topic/75390-ahk-l-Unicode-uri-encode-url-encode-function/
  * @param {string} URI - uniform resource identifier
  * @param {string} [Enc="UTF-8"] - file encoding
  * @returns {string} decoded URI
  */
  uriDecode(Uri, Enc := "UTF-8") {
    Pos := 1
    Loop
    {
      Pos := RegExMatch(Uri, "i)(?:%[\da-f]{2})+", Code, Pos++)
      If (Pos = 0) {
        Break
      }
      VarSetCapacity(Var, StrLen(Code) // 3, 0)
      Code := Substr(Code, 2)
      Loop, Parse, Code, `%
        NumPut("0x" A_LoopField, Var, A_Index - 1, "UChar")
      Uri := StrReplace(Uri, "%" Code, StrGet(&Var, Enc))
    }
    Return, Uri
  }

  /**
  * Copies string to memory address, UTF-16 compatible
  * adapted from: https://autohotkey.com/board/topic/75390-ahk-l-Unicode-uri-encode-url-encode-function/
  * @param {string} Str - string to copy to memory
  * @param {&string} Var - buffer for copied string
  * @param {string} [Enc:="CP0"] - encoding
  * @returns {integer} # of characters written
  */
  putVar(Str, ByRef Var, Enc := "") {
    Len := StrPut(Str, Enc) * (Enc = "UTF-16" || Enc = "CP1200" ? 2 : 1)
    VarSetCapacity(Var, Len, 0)
    Return, StrPut(Str, &Var, Enc)
  }

  /**
  * Expands all environment variables stored in string
  * Must be wrapped in % e.g. %ProgramW6432%, %% for literal %
  * @param {string} str - string with variables
  * @returns {string} string with expanded variables
  */
  expandEnvVars(str) {

    buffer := str
    ; replace variables
    Loop {
      if (!RegExMatch(buffer, "[^%]*%([\w(){}[\]$\*+-\/\x22#',;.@!?]+)%", varName)) {
        break
      }
      EnvGet, varValue, %varName1%
      buffer := StrReplace(buffer, "%" varName1 "%", varValue)
    }
    return StrReplace(buffer, "%%", "%")
  }


  /**
  * Expands all A_ variables stored in string
  * Must be wrapped in % e.g. %A_MyDocuments%, %% for literal %
  * @param {string} str - string with variables
  * @returns {string} string with expanded variables
  */
  expandAhkVars(str) {

    buffer := str
    ; replace variables
    Loop {
      if (!RegExMatch(buffer, "%([Aa]_\w+)%", varName)) {
        break
      }
      varValue = % %varName1%
      buffer := StrReplace(buffer, "%" varName1 "%", varValue)
    }
    return StrReplace(buffer, "%%", "%")
  }

  /**
   * Replaces ${varname} variables in text
   * @param {string} text - string with variables
   * @param {object} variables - variables as key/value pairs
   * @returns {string} text with replaced variables
   *
  */
  expandCustomVars(text, variables) {
    buffer := text
    for key, value in variables {
      buffer := StrReplace(buffer, format("${{}{1}{}}", key), value)
    }
    return buffer
  }

  /**
  * Splits path (Windows, URI) to object
  * @param {string} path - path name
  * @returns {object} {fullName, filename, baseName, ext, dir, drive}
  */
  splitPath(pathName) {
    SplitPath, pathName, fileName, dir, ext, baseName, drive
    ; remove drive from dir
    dir := StrReplace(dir, drive)
    ; fix for root directory (pathname: Windows, protocol e.g. https://)
    if (!dir) {
      slash := Substr(pathname, Strlen(drive) + 1, 1)
      if (InStr("/\", slash )) {
        dir := slash
      }
    }

    return { fullName: (pathName), filename: (fileName)
          , baseName: (baseName), ext: (ext) , dir: (dir), drive: (drive) }
  }

  /**
  * Changes properties in path name  (Windows, URI) - network shares will be treated as drive
  * @param {string} pathName - path name
  * @param {object} options - options object
  * @param {string} [options.filename] - file name
  * @param {string} [options.dir] - directory with leading (back)slash
  * @param {string} [options.ext] - extension
  * @param {string} [options.basename] - base file name
  * @param {string} [options.drive] - drive
  * @returns {string} path with replacements
  */
  buildFileName(pathName, options) {
    path := this.splitPath(pathName)

    if (options.HasKey("filename")) {
      newFilename   := this.splitPath(options.filename)
      path.basename := newFilename.basename
      path.ext      := newFilename.ext
    }

    dir      := options.HasKey("dir") ? options.dir : path.dir
    ext      := options.HasKey("ext") ? options.ext : path.ext
    baseName := options.HasKey("baseName") ? options.baseName : path.baseName
    drive    := options.HasKey("drive") ? options.drive : path.drive

    ; accommodate for web addresses
    slash   := (RegExMatch(pathname, "^\w+:\/\/")) ? "/" : "\"
    dir     := (dir && Substr(dir, 0) != slash) ? dir slash : dir
    return drive dir basename (ext ? "." : "") ext
  }

  /**
  * Transforms a time stamp into a specified date/time format
  * Time stamp can be in 14 digit or 17 digit(only "iso", w/ milliseconds) format
  * @param {string} strFormat - ahk time/date format, or "iso" for JavaScript ISO Date
  * @param {string} [timestamp=A_Now] - time stamp
  * @returns {string} formatted time/date
  */
  formatDateTime(strFormat, timestamp := "") {
    timestamp := this.defaultTo(timestamp, A_Now)
    milliseconds := Substr(timestamp, 15)
    if (strFormat ~= "i)^iso$") {
      ; cspell:disable-next-line
      FormatTime, outputVar, % timestamp, % "yyyy-MM-dd'T'H:mm:ss"
      return Format("{1}.{2}Z", outputVar, milliseconds ? milliseconds : "000")
    }
    FormatTime, outputVar, % substr(timestamp, 1, 14), % strFormat
    return outputVar
  }

  /**
   * Converts string to integer
   * @param {string} str - string
   * @returns {integer | undefined} integer
   *
  */
  parseInt(str) {
    return Format("{1:d}", str)
  }

  ; -- Unicode String Methods --

  /**
    * Returns string length
    * Handles Unicode surrogate pairs better than Strlen
    * @param {string} string - string
    * @returns {integer}
  */
  strLength(string) {
    RegExReplace(string, "s).", "", replaceCount)
    return replaceCount
  }

  /**
    * Converts string to array
    * Handles Unicode surrogate pairs better than StrSplit
    * @param {string} string - string to convert
    * @param {integer} [maxParts:=-1] - maximum number of substrings to return
    * @returns {string[]}
  */
  strToArray(string, maxParts := -1) {
    re := new rd_RegExp()

    matches := re.matchAll(string, "s).", maxParts)
    return re.filterAll(matches, 0)
  }

  /**
    * Retrieves part of string, parameter compatible with Substr
    * Handles Unicode surrogate pairs better than Substr
    * @param {string} string - source string
    * @param {integer} startingPos - starting position
    * @param {string} [length] - length of characters to copy
    * @returns {string} returned substring
  */
  substring(string, startingPos, length := "") {

    if (length = 0) {
      return ""
    }
    strLength := this.strLength(string)
    length    := this.defaultTo(length, strLength)

    if (startingPos < 1) {
      startingPos := strLength + startingPos
    }
    if (length > 0) {
      endingPos := startingPos + length - 1
    } else {
      endingPos := strLength + length
    }

    if (endingPos > strLength) {
      endingPos := strLength
    }

    ; OutputDebug, % "Start: " startingPos " End: " endingPos

    re := new rd_RegExp()

    regex := "s)^"
    if (startingPos > 1) {
      regex .= format(".{{}{1}{}}", startingPos - 1)
    }
    regex .= format("(.{{}{1}{}})", endingPos - startingPos + 1)
    match := re.match(string, regex)
    ; return Substr(string, startingPos, length)
    return match[1]
  }


  ; -- File Methods --

  /**
   * file open wrapper
   * if mode = "w" and a file is overwritten, A_LastError = 183
   * @param {string} fileName - file name
   * @param {string} mode - file open mode
   * @param {string} [encoding=A_FileEncoding] - file encoding
   * @returns {File | undefined} Autohotkey file object
   *
  */
  _fileOpen(fileName, mode, encoding) {
    encoding := this.defaultTo(encoding, A_FileEncoding)
    file := FileOpen(fileName, mode, encoding)
    if (!IsObject(file)) {
      Errorlevel := 1
      this._processError(rd_Utility.ERR_FILEOPEN, fileName)
      return ""
    }
    return file
  }

  /**
   * Writes string to file with opening mode
   * @param {string} text - string to write
   * @param {string} fileName - file name
   * @param {string} mode - file opening mode
   * @param {string} [encoding=A_FileEncoding] - file encoding
   * @returns {integer} number of bytes written
   *
  */
  _fileWriteMode(text, fileName, mode, encoding := "") {
    file := this._fileOpen(fileName, mode, encoding)
    bytesWritten := file.Write(text)
    if ((strlen(text) && bytesWritten = 0) || Errorlevel) {
      this._processError(rd_Utility.ERR_FILEWRITE, filename)
      return 0
    }
    file.Close()
    return bytesWritten
  }

  /**
   * Reads contents of text file into variable
   * @param {string} fileName - file name
   * @param {integer} [maxChars] - maximum number of characters to read
   * @param {string} [encoding=A_FileEncoding] - file encoding
   * @returns {string | undefined} contents of file
   *
  */
  fileRead(fileName, maxChars := 0, encoding := "") {
    file := this._fileOpen(fileName, "r", encoding)
    contents := maxChars ? file.Read(maxChars) : file.Read()
    if (ErrorLevel) {
      this._processError(rd_Utility.ERR_FILEREAD, fileName)
      return ""
    }
    file.Close()
    return contents
  }

  /**
   * Writes string to file (overwrites existing, preserves hard links)
   * If file is overwritten, A_LastError = 183
   * If file didn't exist, A_LastError = 2
   * @param {string} text - string to write
   * @param {string} fileName - file name
   * @param {string} [encoding=A_FileEncoding] - file encoding
   * @returns {integer} number of bytes written
   *
  */
  fileWrite(text, fileName, encoding := "") {
    return this._fileWriteMode(text, fileName, "w", encoding)
  }

  /**
   * Appends string to file
   * @param {string} text - string to append
   * @param {string} fileName - file name
   * @param {string} [encoding=A_FileEncoding] - file encoding
   * @returns {integer} number of bytes written
   *
  */
  fileAppend(text, fileName, encoding := "") {
    return this._fileWriteMode(text, fileName, "a", encoding)
  }

  /**
   * Creates empty file or updates modification date
   * @param {string} fileName - file name
   * @returns {boolean} true, if successful
  */
  fileTouch(fileName) {
    FileAppend,, % fileName
    if (Errorlevel) {
      this._processError(rd_Utility.ERR_FILEOPEN, filename)
      return false
    }
    return true
  }

  /**
   * Creates empty file with unique name
   * Non-existing folders will be created
   * Format: [folder\]prefix-nnnnn.extension
   * @param {string} [extension:=""] - extension of file
   * @param {string} [folder:=A_Temp] - folder name
   * @param {string} [prefix:=Script basename] - file name prefix
   * @returns {string} file name
   *
  */
  createUniqueFile(extension :="", folder :="", prefix :="") {
    extension := LTrim(extension, ".")
    folder := RTrim(this.defaultTo(folder, A_Temp), "\")
    prefix := this.defaultTo(prefix, this.splitPath(A_ScriptFullPath).baseName)

    FileCreateDir, % folder

    Loop {
      Random, number, 10000, 99999
      tempName := folder "\" prefix "-" number
      if (extension) {
        tempName .= "." extension
      }
      if (!FileExist(tempName)) {
        break
      }
    }
    this.fileTouch(tempName)
    return tempName
  }


  ; -- utility methods --

  /**
   * Generic error handler
   * @param {message} message - error message with placeholders
   * @param {string*} param - parameters (variadic)
   *
  */
  _processError(message, param*) {
    if (rd_Utility.throwExceptions) {
      throw Exception(format(message, param*), -2)
    }
  }

  /**
   * Retrieves Windows error message text for error number
   * cf. https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-formatmessagew
   * @param {integer} number - Windows error number (A_LastError)
   * @param {integer} [languageId:=0] - language identifier cf. https://www.autohotkey.com/docs/misc/Languages.htm
   *    for languageId != 0, language must be installed
   * @returns {string | undefined} error message
   *
  */
  getWindowsErrorText(number, languageId := 0) {
    static FORMAT_MESSAGE_ALLOCATE_BUFFER := 0x100
          , FORMAT_MESSAGE_IGNORE_INSERTS := 0x200
          , FORMAT_MESSAGE_FROM_SYSTEM := 0x1000

    if (!length := DllCall("Kernel32.dll\FormatMessageW"
        , "UInt", FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS
        , "Ptr",  0
        , "UInt", number
        , "UInt", languageId
        , "Ptr*", buffer
        , "UInt", 0
        , "Ptr",  0)) {
          return ""
        }

    errorMsg := StrGet(buffer, length, "UTF-16")
    DllCall("Kernel32.dll\LocalFree", "Ptr", buffer)

    return RTrim(errorMsg, "`r`n")
  }

  /**
   * Checks value to determine whether a default value should be returned in its place
   * @param {string|number} variable - variable to check
   * @param {string|number} default - default value
   * @returns {string|number} variable or default
  */
  defaultTo(variable, default) {
    return variable != "" ? variable : default
  }



}