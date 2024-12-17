#Requires AutoHotkey v2.0

; Global Variables
documentsPath := A_MyDocuments
searchTerms := ["Secret", "Password"]
contextLength := 30
results := ""

; Function to find context around search terms
FindContext(content, terms, length)
{
    resultArray := []
    Loop terms.MaxIndex()
    {
        term := terms[A_Index]
        pos := 1
        While (pos := InStr(content, term, false, pos))
        {
            startPos := pos - length
            if (startPos < 1)
                startPos := 1
            context := SubStr(content, startPos, length * 2)
            resultArray.Push(term "`: " context)
            pos += StrLen(term)
        }
    }
    return resultArray
}

; Search all .txt files in the Documents folder
FileList := []
; Use the Loop command to iterate through all .txt files in the Documents folder
Loop % documentsPath %"\*.txt"
    {
        ; Push the full path of each found .txt file to the FileList array
        FileList.Push(A_LoopFileFullPath)
    }

if (FileList.MaxIndex() == 0) {
    MsgBox("No .txt files found", "Error")
    ExitApp
}

Loop FileList.MaxIndex()
{
    filePath := FileList[A_Index]
    fileContent := ""
    try fileContent := FileRead(filePath)
    catch
    {
        Continue
    }

    fileResults := FindContext(fileContent, searchTerms, contextLength)
    Loop fileResults.MaxIndex()
    {
        results .= filePath "`: " fileResults[A_Index] "`n"
    }
}

; Write the results to a text file
outputFilePath := A_ScriptDir "\output.txt"
FileDelete(outputFilePath)
FileAppend(results, outputFilePath, "UTF-8")

MsgBox("Results written to " outputFilePath)
