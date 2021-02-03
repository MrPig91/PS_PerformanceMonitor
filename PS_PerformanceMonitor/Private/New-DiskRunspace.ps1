function New-DiskRunspace {
    [powershell]::Create().AddScript{
        Add-Type -AssemblyName PresentationFramework
        #Import required assemblies and private functions
        Get-childItem -Path $DataHash.PrivateFunctions -File | ForEach-Object {Import-Module $_.FullName}
        Get-childItem -Path $DataHash.Assemblies -File | ForEach-Object {Add-Type -Path $_.FullName}
        Get-childItem -Path $DataHash.Classes -File | ForEach-Object {Import-Module $_.FullName}
    
        try{
            $X = Get-Date

            $UIHash.DiskDefaultCounterComboBox.Dispatcher.Invoke([action]{$DataHash.DiskCounter = $UIHash.DiskDefaultCounterComboBox.SelectedItem.Counter})

            $computers = $DataHash.addedComputers | where IsChecked -eq $true
            $UIHash.TimeIntervalSlider.Dispatcher.Invoke([action]{$DataHash.DiskIntervalX = $UIHash.TimeIntervalSlider.Value})
            $DataHash.DiskX -= $DataHash.DiskIntervalX
    
            Get-Counter -Counter $DataHash.DiskCounter -Continuous -ComputerName $computers.ComputerName -SampleInterval $DataHash.DiskIntervalX -ErrorAction Stop -ErrorVariable ErrVar -OutVariable DiskLogs |
            select -expandProperty CounterSamples |
             foreach -Begin {
                $DiskFilePrefix = Get-Date -Format "yyyyMMdd(s)"
             } -Process {
                if ($DataHash.DiskSeriesCollectionTitles.Title -notcontains $_.Path){
                    $newRandomColor = ([System.Windows.Media.Colors] | gm -Static -MemberType Properties)[(Get-Random -Minimum 0 -Maximum 141)].Name
    
                    $plus1 = ($DataHash.DiskSeriesCollectionTitles | Measure).Count + 1
                    $newIndex = [PSCustomObject]@{
                        Title = $_.Path
                        Index = $plus1
                    }
    
                    $DataHash.DiskSeriesCollectionTitles.Add($newIndex)
                    $newCounterListViewItem = $DataHash.DiskListViewList[$plus1]
                    $newCounterListViewItem.Name = $_.Path
                    $newCounterListViewItem.Counter = ($_.Path.Split('\',[System.StringSplitOptions]::RemoveEmptyEntries)[1].split('(')[0])
                    $newCounterListViewItem.ComputerName = ($_.Path.Split('\',[System.StringSplitOptions]::RemoveEmptyEntries)[0])
                    $newCounterListViewItem.Instance =  $_.InstanceName
                    $newCounterListViewItem.Units = ($_.Path.Split('\',[System.StringSplitOptions]::RemoveEmptyEntries)[2])
                    $newCounterListViewItem.Value = 0
                    $newCounterListViewItem.LineColor = $newRandomColor
                    $newCounterListViewItem.LineThickness = 2
                    $DataHash.DiskListViewItems.Add($newCounterListViewItem)
    
                    $UIHash.DiskLineChart.Dispatcher.Invoke([action]{
                    $UIHash.DiskChartSeries[$plus1].Title = $_.Path
                    $UIHash.DiskChartSeries[$plus1].PointGeometrySize = 2
                    $UIHash.DiskChartSeries[$plus1].LineSmoothness = .2
                    $CloneStrokeColor = $UIHash.DiskChartSeries[$plus1].Stroke.Clone()
                    $CloneFillColor = $UIHash.DiskChartSeries[$plus1].Fill.Clone()
                    $CloneFillColor.Color = [System.Windows.Media.Colors]::$newRandomColor
                    $UIHash.DiskChartSeries[$plus1].Fill = $CloneFillColor
                    $CloneStrokeColor.Color = [System.Windows.Media.Colors]::$newRandomColor
                    $UIHash.DiskChartSeries[$plus1].Stroke = $CloneStrokeColor
    
                    #Set Line Series Visibility to the listviewItem checkbox status
                    $Binding = New-Object System.Windows.Data.Binding
                    $Binding.Path = [System.Windows.PropertyPath]::new("IsChecked")
                    $Binding.Converter = [System.Windows.Controls.BooleanToVisibilityConverter]::new()
                    $Binding.Source = $DataHash.DiskListViewItems | where Name -eq $_.Path
                        [void][System.Windows.Data.BindingOperations]::SetBinding($UIHash.DiskChartSeries[$plus1],[LiveCharts.Wpf.LineSeries]::VisibilityProperty, $Binding)
                    })
                    
                }
                
                if ($X -lt $_.Timestamp){
                    $X = $_.Timestamp
                    $DataHash.DiskX += $DataHash.DiskIntervalX
                }
    
                $CookedValue = [Math]::Round($_.CookedValue,2)
                $newPoint = [LiveCharts.Defaults.ObservablePoint]::new($DataHash.DiskX,$CookedValue)

                $index = ($DataHash.DiskSeriesCollectionTitles | where Title -eq $_.Path).Index
                $DataHash.DiskChartValues[$index].Add($newPoint)
    
                $Item = $DataHash.DiskListViewItems | where Name -eq $_.Path
                $Item.Value = $CookedValue
    
                if ($DiskHash.Logging.Checked){
                    if (Test-Path $DiskHash.FilePath.Text){
                        $DiskLogs | Export-Counter -Path "$($DiskHash.FilePath.Text.TrimEnd("\"))\$DiskFilePrefix-DiskCounterLogs.$($DiskHash.FileFormat.SelectedItem)" -FileFormat $DiskHash.FileFormat.SelectedItem -Force
                    }
                }
            }
        }
        catch{
            Show-Messagebox -Title "Disk Runspace" -Text "$($_.Exception.Message)" -Icon Error
            $UIHash.DiskStopButton.Dispatcher.Invoke([action]{$UIHash.DiskStopButton.Enabled = $false})
            $UIHash.DiskStartButton.Dispatcher.Invoke([action]{$UIHash.DiskStartButton.Enabled = $true})
        }
    }
}