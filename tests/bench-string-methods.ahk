#NoEnv
#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
FileEncoding, UTF-8-RAW

SetBatchLines, -1
ListLines, Off

#include, %A_ScriptDir%\rd_Bench.ahk
#Include, %A_ScriptDir%\..\rd_Utility.ahk

OnError("ShowError")

global U := new rd_Utility()

runBench()

SoundBeep

ExitApp

runBench() {

  fileContents := U.fileRead("bench-string-data.txt")

  bc := new rd_Bench({ iterations: 1000 })
  bc.benchFunc("SubStr", func("Substr").bind(fileContents, 250, 1000))
  bc.benchFunc("U.substring", objBindMethod(U, "substring", fileContents, 250, 1000))
  bc.benchFunc("U.strToArray", objBindMethod(U, "strToArray", fileContents, 500))
}

ShowError(exception) {
    Msgbox, 16, Error, % "Error in " exception.what " on line " exception.Line "`n`n" exception.Message " (" A_LastError ")"  "`n"
    return true
}
