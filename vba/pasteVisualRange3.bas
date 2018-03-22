Private Sub pasteVisualRange3()
    On Error Resume Next
    Dim message1, Title1, message2, Title2
    Dim sourceRange As Range, distRange As Range, cell As Range, startCell As Range
    Dim rowColumnStr As String, str As String, sheetName As String, workbookName As String
    Dim i As Long, j%, rIndex As Long, dRowIndex As Long, jIndex%, sourceVisualRowCounter As Long, sourceVisualColumnCounter%
    Dim d As Object, WsShell As Object
    Dim recordCount As Long, sleepTime As Integer
    
    Set WshShell = CreateObject("Wscript.Shell")
    
    '##################################选择单元格区域########################
rechoiceSource:
    message1 = "请选择你要粘贴的数据源的区域："
    Title1 = "数据源区域"
    Set sourceRange = Application.InputBox(prompt:=message1, Title:=Title1, Type:=8) 'inputbox需要接收返回值
    
    If sourceRange.Rows.Count = 0 Or sourceRange.Columns.Count = 0 Then
        GoTo rechoiceSource
    End If
    
    str = "选择区域共" & vbCtLf & sourceRange.Rows.Count & "行" & vbCtLf & sourceRange.Columns.Count & "列" & vbCtLf & "确认选择吗？"
    recordCount = sourceRange.Rows.Count * sourceRange.Columns.Count
    sleepTime = getSleepTime(recordCount)
    If sourceRange.Rows.Count * sourceRange.Columns.Count > 100000 Then
        If vbCancel = (MsgBox(str, vbOKCancel + vbDefaultButton2, "确认选择")) Then '之前从网上抄的messageButtonStyle.vbOKCancel,这种会报错
            GoTo rechoiceSource
        End If
    End If
    
    Set d = CreateObject("scripting.dictionary") '创建字典
    
rechoice:
    message2 = "请选择目标位置的起始单元格："
    Title2 = "目标起始单元格"
    Set distRange = Application.InputBox(message2, Title2, , , , , , Type:=8)
    
    If distRange.Columns.Count <> 1 Or distRange.Rows.Count <> 1 Then
        MsgBox "起始单元格只能选择一个单元格，请重新选择"
        GoTo rechoice
    End If
    
    If distRange.Width = 0 And distRange.Height = 0 Then
        MsgBox "起始单元格不能选在隐藏区域,请重新选择"
        GoTo rechoice
    End If
    Set startCell = distRange(1, 1)
    '##################################选择单元格区域########################
    
    '##################激活粘贴目标工作表##########################
    str = distRange.Address(External:=True) '查找字符串函数lnStr,这个和工作表函数不一样
    sheetName = distRange.Parent.Name
    workbookName = distRange.Parent.Parent.Name
    Workbooks(workbookName).Sheets(sheetName).Activate
    'MsgBox "当前活动工作簿为：" & vbCrLf & ActiveWorkbook.Name & vbCrLf & "活动工作表为：" & ActiveSheet.Name '换行显示
    '这里时间是int类型的，所以不能少于1秒
    '这个定时器有可能会失效，失效就手动点击或者重启Application
    WshShell.Popup "当前活动工作簿为：" & vbCrLf & ActiveWorkbook.Name & vbCrLf & "活动工作表为：" & ActiveSheet.Name, 1, "1秒后关闭！"
    '##################激活粘贴目标工作表##########################
    
    '##################################操作单元格########################
    Set cell = sourceRange(1, 1).Offset(rIndex, cIndex)

    For i = sourceRange.Row To sourceRange.Row + sourceRange.Rows.Count - 1 Step 1
        If cell.Height <> 0 Then
            sourceVisualRowCounter = sourceVisualRowCounter + 1
        Else
            GoTo NextI
        End If
        For j = sourceRange.Column To sourceRange.Column + sourceRange.Columns.Count - 1 Step 1
                Set cell = sourceRange(1, 1).Offset(rIndex, cIndex)
                If cell.Width <> 0 Then
                    sourceVisualColumnCounter = sourceVisualColumnCounter + 1
                    Debug.Print distRange.Address & "--->" & cell.Address
                    distRange.Value = cell.Value
                    If j < sourceRange.Columns.Count Then
                        Set distRange = returnDistCell(distRange, False)
                    End If
                Else
                    GoTo NextJ
                End If
NextJ:
                cIndex = cIndex + 1
        Next j
NextI:
        rIndex = rIndex + 1
        cIndex = 0
        Set cell = sourceRange(1, 1).Offset(rIndex, cIndex)
        If cell.Height <> 0 Then
            '这里把下一个可见行的第一列的上一行的单元格对象传递过去，下一个可见单元格只需要便宜一行0列的位置即可获得
            Set distRange = returnDistCell(Cells(distRange.Row, startCell.Column), True)
        End If
    Next i
    WshShell.Popup "复制完成", 1, "1秒后关闭！"
    Set WshShell = Nothing
    Set d = Nothing

End Sub


Public Function returnDistCell(ByRef cell As Range, isRowIndexChanged As Boolean) As Range
    Dim index As Integer
    If isRowIndexChanged = False Then '如果换行了，索引值默认为0
        index = 1
        If cell.Offset(0, index).Width <> 0 Then
            Set returnDistCell = cell.Offset(0, index)
        Else
            Do Until cell.Offset(0, index).Width <> 0
                index = index + 1
            Loop
            Set returnDistCell = cell.Offset(0, index)
        End If
    Else
        index = 1
        If cell.Offset(index, 0).Height <> 0 Then
            Set returnDistCell = cell.Offset(index, 0)
        Else
            Do Until cell.Offset(index, 0).Height <> 0
                index = index + 1
            Loop
            Set returnDistCell = cell.Offset(index, 0)
        End If
    End If
    
    Debug.Print "下一个目标地址为：" & returnDistCell.Address(1, 1, External:=True)
End Function

Public Function getSleepTime(ByVal recordCount As Long) As Integer
     getSleepTime = Application.WorksheetFunction.Ceiling(recordCount / 50000, 1)
End Function
