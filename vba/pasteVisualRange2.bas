
Private Sub pasteVisualRange2()
    On Error Resume Next
    Dim message1, Title1, message2, Title2
    Dim sourceRange As Range, distRange As Range, cell As Range, shapedRange As Range
    Dim counter As Integer, index As Integer, rowOffset As Integer, columnOffset As Integer, hiddenRowCounter As Integer, hiddenColumnCounter As Integer
    Dim sourceVisualRowCounter%, sourceVisualColumnCounter%, distVisualRowCounter%, distVisualColumnCounter%, StartRow%, startColumn%, rowCounter%
    Dim rowColumnStr As String, str As String, sheetName As String, workbookName As String
    Dim d As Object, WsShell As Object
    Dim arr As Variant, columnArr As Variant, rowArr As Variant
    Dim recordCount As Long, sleepTime As Integer
    Dim LoopState As Byte
    
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
    
    '##################################把数据源存放在字典当中########################
    LoopState = 0
COLUMNLOOP:
    For Each cell In Range(sourceRange(1, 1), sourceRange(1, sourceRange.Columns.Count))
        If cell.MergeCells Then
            MsgBox "第" & cell.Column & "列为合并单元格区域，不能处理，请解除合并单元格"
        Exit Sub
        End If
        If cell.Width <> 0 Then
            sourceVisualColumnCounter = sourceVisualColumnCounter + 1
            If LoopState = 1 Then
                columnArr(sourceVisualColumnCounter) = cell.Column
            End If
        End If
    Next
    LoopState = LoopState + 1
    If LoopState = 1 Then
        ReDim columnArr(1 To sourceVisualColumnCounter)
        sourceVisualColumnCounter = 0
        GoTo COLUMNLOOP
    End If
    
    LoopState = 0
ROWLOOP:
    For Each cell In Range(sourceRange(1, 1), sourceRange(sourceRange.Rows.Count, 1))
        cell.Activate
        If cell.MergeCells Then
            MsgBox "第" & cell.Row & "行为合并单元格区域，不能处理，请解除合并单元格"
        Exit Sub
        End If
        If cell.Height <> 0 Then
            sourceVisualRowCounter = sourceVisualRowCounter + 1
            If LoopState = 1 Then
                rowArr(sourceVisualRowCounter) = cell.Row
            End If
        End If
    Next
    LoopState = LoopState + 1
    If LoopState = 1 Then
        ReDim rowArr(1 To sourceVisualRowCounter)
        sourceVisualRowCounter = 0
        GoTo ROWLOOP
    End If
    
    For i = 1 To sourceVisualRowCounter + 1 Step 1
        ReDim arr(0 To sourceVisualColumnCounter) '定义一个数据源可见区域的二维数组
        For j = 1 To sourceVisualColumnCounter + 1 Step 1
            Debug.Print Cells(87, 1)
            arr(j) = Cells(rowArr(i), columnArr(j)).Value
        Next j
        d.Add i, arr
    Next i
    
    Debug.Print d.Item(3)(1)
    
    'MsgBox "当前选择区域的可见行列数为" & sourceVisualRowCounter & "行" & sourceVisualColumnCounter - 1 & "列"
    WshShell.Popup "当前选择区域的可见行列数为" & sourceVisualRowCounter & "行" & sourceVisualColumnCounter - 1 & "列", sleepTime, sleepTime & "秒后关闭！"
    '##################################把数据源存放在字典当中########################
    
End Sub

Private Sub exitSubWhenMergeRange(ByVal cell As Range)
    If cell.MergeArea Then
        MsgBox "第" & cell.Column & "列为合并单元格区域，不能处理，请解除合并单元格"
    Exit Sub
End Sub
