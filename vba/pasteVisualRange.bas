Private Sub pasteVisualRange()
    On Error Resume Next
    Dim message1, Title1, message2, Title2
    Dim sourceRange As Range, distRange As Range, cell As Range, shapedRange As Range
    Dim counter As Integer, index As Integer, rowOffset As Integer, columnOffset As Integer, hiddenRowCounter As Integer, hiddenColumnCounter As Integer
    Dim sourceVisualRowCounter%, sourceVisualColumnCounter%, distVisualRowCounter%, distVisualColumnCounter%, StartRow%, startColumn%, rowCounter%
    Dim rowColumnStr As String, str As String, sheetName As String, workbookName As String
    Dim d As Object, WsShell As Object
    Dim arr As Variant
    
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
    
    
    ''##################激活粘贴目标工作表##########################
    str = distRange.Address(External:=True) '查找字符串函数lnStr,这个和工作表函数不一样
    sheetName = distRange.Parent.Name
    workbookName = distRange.Parent.Parent.Name
    Workbooks(workbookName).Sheets(sheetName).Activate
    'MsgBox "当前活动工作簿为：" & vbCrLf & ActiveWorkbook.Name & vbCrLf & "活动工作表为：" & ActiveSheet.Name '换行显示
    '这里时间是int类型的，所以不能少于1秒
    '这个定时器有可能会失效，失效就手动点击或者重启Application
    WshShell.Popup "当前活动工作簿为：" & vbCrLf & ActiveWorkbook.Name & vbCrLf & "活动工作表为：" & ActiveSheet.Name, 1, "1秒后关闭！"
    ''##################激活粘贴目标工作表##########################
    
    '##################################把数据源存放在字典当中########################
    counter = 0
    sourceVisualRowCounter = 0
    sourceVisualColumnCounter = 0
    For Each cell In sourceRange
        If cell.MergeCells Then
            MsgBox cell.Address & "为合并单元格区域，不能处理，请解除合并单元格"
            Exit Sub
        End If
        cell.Select
        If cell.Height <> 0 And cell.Width <> 0 Then
        'foreach循环没有跳过当前循环的控制语句
            If cell.Row <> index Then
                sourceVisualColumnCounter = 1
                sourceVisualRowCounter = sourceVisualRowCounter + 1
            End If
            counter = counter + 1
            rowColumnStr = sourceVisualRowCounter & "," & sourceVisualColumnCounter & "," & cell.Value
            d.Add counter, rowColumnStr
            sourceVisualColumnCounter = sourceVisualColumnCounter + 1
            index = cell.Row
        End If
    Next
    
    'MsgBox "当前选择区域的可见行列数为" & sourceVisualRowCounter & "行" & sourceVisualColumnCounter - 1 & "列"
    WshShell.Popup "当前选择区域的可见行列数为" & sourceVisualRowCounter & "行" & sourceVisualColumnCounter - 1 & "列", 1, "1秒后关闭！"
    '##################################把数据源存放在字典当中########################
    
    '##################################把字典中的值转存到目标区域中########################
    index = 1
    rowCounter = 0
    sourceVisualColumnCounter = sourceVisualColumnCounter - 1
    
    StartRow = distRange.Cells(1).Row
    startColumn = distRange.Cells(1).Column
    
    hiddenRowCounter = 0
    hiddenColumnCounter = 0
    
    Set shapedRange = distRange(Cells(StartRow, startColumn), Cells(rowOffset, columnOffset))
    Application.ScreenUpdating = False
    
nextRow:
    Do While distVisualRowCounter < sourceVisualRowCounter
nextColumn:
    Do While distVisualColumnCounter < sourceVisualColumnCounter
            '计算偏移量
            rowOffset = StartRow + distVisualRowCounter + hiddenRowCounter
            columnOffset = startColumn + distVisualColumnCounter + hiddenColumnCounter
            '设置单元格,这里也可以用offset函数去偏移
            'distRange(Cells(rowOffset, columnOffset), Cells(rowOffset, columnOffset)).Select 不能使用这种方式移动，否则单元格移动方向有问题
            distRange.Offset(distVisualRowCounter + hiddenRowCounter, distVisualColumnCounter + hiddenColumnCounter).Select
            rowColumnStr = distRange.Offset(distVisualRowCounter + hiddenRowCounter, distVisualColumnCounter + hiddenColumnCounter).Address
            
            If distRange.Offset(distVisualRowCounter + hiddenRowCounter, distVisualColumnCounter + hiddenColumnCounter).Width = 0 Then
                hiddenColumnCounter = hiddenColumnCounter + 1
                GoTo nextColumn
            End If

            If distRange.Offset(distVisualRowCounter + hiddenRowCounter, distVisualColumnCounter + hiddenColumnCounter).Height <> 0 And _
            distRange.Offset(distVisualRowCounter + hiddenRowCounter, distVisualColumnCounter + hiddenColumnCounter).Width <> 0 Then
                distVisualColumnCounter = distVisualColumnCounter + 1
                arr = Split(d.Item(index), ",")
                Cells(rowOffset, columnOffset).Value = arr(2)
                index = index + 1
            End If
        Loop
        'columnOffset = startColumn
        rowCounter = rowCounter + 1
        distRange.Offset(rowCounter, 0).Select
        If distRange.Offset(rowCounter, 0).Height <> 0 Then
            distVisualRowCounter = distVisualRowCounter + 1
            '当换行后，新的行高不为0，列的参数需要初始化
            distVisualColumnCounter = 0
            hiddenColumnCounter = 0
        Else
            hiddenRowCounter = hiddenRowCounter + 1
            GoTo nextRow
        End If
    Loop
    '##################################把字典中的值转存到目标区域中########################
    Application.ScreenUpdating = True
    WshShell.Popup "复制完成", 1, "1秒后关闭！"
    Set WshShell = Nothing
    Set d = Nothing
    
End Sub

Public Sub 录入对话()
    '过程,"弹出对话","对话框标题",图标类型,默认参数,N秒后自动关闭
    MsgBoxTimeOut 0, "录入完毕!!", "提示", 64, 0, 1500
End Sub

