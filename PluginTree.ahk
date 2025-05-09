#Requires AutoHotkey v2.0
#SingleInstance Force

GenPluginTree(PluginDir, MakeSubmods := true, Manifest := "") {
  Manifest := DirToManifest(PluginDir, Manifest)
  
  OldDir := A_WorkingDir
  SetWorkingDir PluginDir
  {
    contents := ""
    Loop Files, "*.ahk" {
      If SubStr(A_LoopFileName, 1, 1) != "_" {
        if A_LoopFilePath != Manifest
          contents .= "#include " . A_LoopFilePath "`n"
      }
    }

    subMods := ""
    Loop Files, "*", "D" {
    If SubStr(A_LoopFileName, 1, 1) != "_"
      minifest := GenPluginTree(A_LoopFilePath, false)
      subMods .= "  #include " . minifest "`n"
    }
  } SetWorkingDir OldDir

  if subMods != "" {
    if MakeSubmods {
      WriteAutoGen(PluginDir, "_submods.ahk", subMods)
    }
    contents := "  `;SUBMODULES`n" . subMods . "  `;SUBMODULES`n`n" . contents
  }
  WriteAutoGen(PluginDir, Manifest, contents)
  return  PluginDir . "\" . Manifest
}

WriteAutoGen(Dir, FileName, Contents) {
  FilePath := Dir "\" . FileName
  Write(Str) {
    FileAppend Str, FilePath
  }
  FileTryDelete(FilePath) ; make room to populate the file
  Write "; THIS FILE WAS AUTO-GENERATED BY 'PluginTree.ahk'.`n"
  Write "  `; MANUAL CHANGES MAY BE OVERWRITTEN `n`n"
  Write "#Requires AutoHotkey v2.0`n`n"
  Write contents
  Write "`n#HotIf"
}

DirToManifest(Dir, FileName := "") {
  if not FileName {
    SplitPath(Dir, &FileName)
    FileName := StrLower(FileName) ".ahk"
  }
  return "_" . FileName
}

; Also Should be in a library...
FileTryDelete(FilePath) {
  if FileExist(FilePath) {
    FileDelete FilePath
  }
}