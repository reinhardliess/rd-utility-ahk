 ; cspell:disable
#NoEnv
; #SingleInstance force
#Warn All, OutputDebug
; #Warn, UseUnsetLocal, Off
#NoTrayIcon

SetWorkingDir, %A_ScriptDir%

#Include, %A_ScriptDir%\..\rd_Utility.ahk
#Include, %A_ScriptDir%\..\node_modules\rd-regexp-ahk\rd_RegExp.ahk
#Include, %A_ScriptDir%\..\node_modules\unit-testing.ahk\export.ahk

; set defaults
StringCaseSense Locale

; for timings
SetBatchLines, -1

global assert := new unittesting()

OnError("ShowError")

; -Tests --

assert.group("Utility Class")
test_utility()

; -End of tests --

assert.fullReport()
assert.writeTestResultsToFile()

ExitApp, % assert.failTotal

test_utility() {

  ; -- string methods --

  assert.label("convertToWrap")
  newStr   := U.convertToWrap(" The quick brown fox jumped over the incre-`r`ndibly lazy   dog.`r`n`r`nline3`r`nline4")
  expected := "The quick brown fox jumped over the incredibly lazy dog.`r`n`r`nline3 line4"
  assert.equal(newStr, expected)

  assert.label("encode/decode URI")
  assert.equal(U.uriDecode(U.uriEncode("老子")), "老子")

  assert.label("expandAhkVars - test will fail if this file isn't called all-tests.ahk")
  assert.equal(U.expandAhkVars("50%%. This is %A_ScriptName%."), "50%. This is all-tests.ahk.")
  assert.equal(U.expandAhkVars("no variables"), "no variables")

  assert.label("expandEnvVars - test will fail if Windows isn't installed on C:")
  assert.equal(U.expandEnvVars("%windir%\MEDIA\Alarm01.wav"), "C:\WINDOWS\MEDIA\Alarm01.wav")

  assert.label("expandCustomVars - expand ${} variables in text")
  actual := U.expandCustomVars("This is a ${var1} with 2 ${var2}"
    , { var1: "string", var2: "variables"})
  assert.test(actual, "This is a string with 2 variables")

  assert.label("formatDateTime")
  assert.equal(U.formatDateTime("ISO", "20210314141522"), "2021-03-14T14:15:22.000Z")
  assert.equal(U.formatDateTime("ISO", "20210314141522123"), "2021-03-14T14:15:22.123Z")
  assert.equal(U.formatDateTime("HH:mmm MM/dd", "20210314141522"), "14:15 03/14")

  assert.label("parseInt")
  assert.equal(U.parseInt("34s"), 34)
  assert.equal(U.parseInt("344567"), 344567)
  assert.equal(U.parseInt("0x64"), 100)

  assert.label("splitPath")
  oPath := U.splitPath("C:\Batch\Test1.bat")
  assert.equal(oPath, { filename: "Test1.bat", dir: "\Batch", ext: "bat"
    , baseName: "Test1", drive: "C:", fullName: "C:\Batch\Test1.bat"})

  oPath := U.splitPath("C:\Test1.bat")
  assert.equal(oPath, { filename: "Test1.bat", dir: "\", ext: "bat"
    , baseName: "Test1", drive: "C:", fullName: "C:\Test1.bat"})

  oPath := U.splitPath("Test1.bat")
  assert.equal(oPath, { filename: "Test1.bat", dir: "", ext: "bat"
    , baseName: "Test1", drive: "", fullName: "Test1.bat"})

  oPath := U.splitPath("D:Test1.bat")
  assert.equal(oPath, { filename: "Test1.bat", dir: "", ext: "bat"
    , baseName: "Test1", drive: "D:", fullName: "D:Test1.bat"})

  oPath := U.splitPath("\\share\sub\Test1.bat")
  assert.equal(oPath, { filename: "Test1.bat", dir: "\sub", ext: "bat"
    , baseName: "Test1", drive: "\\share", fullName: "\\share\sub\Test1.bat"})

  oPath := U.splitPath("\\share\Test1.bat")
  assert.equal(oPath, { filename: "Test1.bat", dir: "\", ext: "bat"
    , baseName: "Test1", drive: "\\share", fullName: "\\share\Test1.bat"})

  oPath := U.splitPath("https://domain.com/dir/Test1.html")
  assert.equal(oPath, { filename: "Test1.html", dir: "/dir", ext: "html"
    , baseName: "Test1", drive: "https://domain.com", fullName: "https://domain.com/dir/Test1.html"})

  oPath := U.splitPath("https://domain.com/Test1.html")
  assert.equal(oPath, { filename: "Test1.html", dir: "/", ext: "html"
    , baseName: "Test1", drive: "https://domain.com", fullName: "https://domain.com/Test1.html"})

  assert.label("buildFileName")
  assert.equal(U.buildFileName("D:\test\work.txt", {drive: "c:"}), "c:\test\work.txt")
  assert.equal(U.buildFileName("D:\test\work.txt", {dir: "\subdir", drive: "X:"}), "x:\subdir\work.txt")
  assert.equal(U.buildFileName("D:\test\work.txt", {drive: "c:", filename: "abc.txt"}), "c:\test\abc.txt")
  assert.equal(U.buildFileName("D:\work.txt", {drive: "c:"}), "c:\work.txt")
  assert.equal(U.buildFileName("work.txt", {drive: "c:"}), "c:work.txt")
  assert.equal(U.buildFileName("work.txt", {ext: ""}), "work")
  assert.equal(U.buildFileName("https://domain.com/Test1.html", {ext: "htm"}), "https://domain.com/Test1.htm")
  assert.equal(U.buildFileName("https://domain.com/subdir/Test1.html", {dir: "/pics"}), "https://domain.com/pics/Test1.html")

  ; -- Unicode String Methods --

  string1 := "🎈abc🤣d"
  string2 := "The quick brown fox"
  assert.label("strLength")
  assert.test(U.strLength(string1), 6)

  assert.label("strToArray")
  assert.test(U.strToArray(string1), ["🎈","a", "b", "c", "🤣", "d"])

  assert.label("substring")
  assert.test(U.substring(string2, -3), Substr(string2, -3))
  assert.test(U.substring(string2, 11), Substr(string2, 11))
  assert.test(U.substring(string2, 1, -1), Substr(string2, 1, -1))
  assert.test(U.substring(string2, -4, -1), Substr(string2, -4, -1))
  assert.test(U.substring(string1, -1), "🤣d")

  ; -- file methods --

  assert.label("fileWrite")
  assert.test(U.fileWrite("A line of text`r`n", "temp-test.txt", "UTF-8-RAW"), 16)

  assert.label("fileAppend")
  assert.test(U.fileAppend("More text`r`n", "temp-test.txt"), 11)

  assert.label("fileRead")
  assert.test(U.fileRead("temp-test.txt"), "A line of text`r`nMore text`r`n")

  assert.label("createUniqueFile")
  fileName := U.createUniqueFile("tmp", A_Temp "\ahk-tests")

  FileGetSize, fileSize, % fileName
  FileDelete, % fileName
  assert.test(fileSize, 0)

  ; -- utility methods --

  assert.label("defaultTo")
  assert.equal(U.defaultTo(undefinedVar1, 33), 33)
  assert.equal(U.defaultTo(0, 33), 0)

}

ShowError(exception) {
    Msgbox, 16, Error, % "Error in " exception.what " on line " exception.Line "`n`n" exception.Message " (" A_LastError ")"  "`n"
    return true
}
