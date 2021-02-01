function New-UIRunspace{
    [powershell]::Create().AddScript{
        $ErrorActionPreference = "Stop"
        Add-Type -AssemblyName PresentationFramework
        #Import required assemblies and private functions
        Get-childItem -Path $DataHash.PrivateFunctions -File | ForEach-Object {Import-Module $_.FullName}
        Get-childItem -Path $DataHash.Assemblies -File | ForEach-Object {Add-Type -Path $_.FullName}

        Try{
            $XAMLPath = Join-Path -Path $DataHash.WPF -ChildPath MainWindow.xaml
            $MainWindow = Import-Xaml -Path $XAMLPath
            $UIHash.MainWindow = $MainWindow

            #Tabs
            $UIHash.MainTablControl = $MainWindow.FindName("MainTabControl")
            $UIHash.CPUTabPage = $MainWindow.FindName("CPUTabPage")

            #Buttons
            $UIHash.AddComputerButton = $MainWindow.FindName("AddComputerButton")
            $UIHash.SelectAllButton = $MainWindow.FindName("SelectAllButton")
            $UIHash.DeSelectAllButton = $MainWindow.FindName("DeSelectAllButton")
            $UIHash.RemoveSelectedButton = $MainWindow.FindName("RemoveSelectedButton")

            #Textboxes
            $UIHash.computerSearchbox = $MainWindow.FindName("computerSearchbox")
            $UIHash.ComputerSearchbox.IsEnabled = $false
            $UIHash.FilePathBox = $MainWindow.FindName("LogPathTextbox")
            $UIHash.FilePathBox.Text = "$ENV:USERPROFILE\Downloads"

            #Comboboxes
            $UIHash.CPUDefaultCounterComboBox = $MainWindow.FindName("defaultCPUCounterCombobox")
            $UIHash.CPUDefaultCounterComboBox.DisplayMemberPath = "FriendlyName"
            $UIHash.NetworkDefaultCounterComboBox = $MainWindow.FindName("defaultNetworkCounterCombobox")
            $UIHash.NetworkDefaultCounterComboBox.DisplayMemberPath = "FriendlyName"
            $UIHash.DiskDefaultCounterComboBox = $MainWindow.FindName("defaultDiskCounterCombobox")
            $UIHash.DiskDefaultCounterComboBox.DisplayMemberPath = "FriendlyName"
            $UIHash.MemoryDefaultCounterComboBox = $MainWindow.FindName("defaultMemoryCounterCombobox")
            $UIHash.MemoryDefaultCounterComboBox.DisplayMemberPath = "FriendlyName"
            $UIHash.ThermalsDefaultCountersCombo = $MainWindow.FindName("defaultThermalCounterCombobox")
            $UIHash.ThermalsDefaultCountersCombo.DisplayMemberPath = "FriendlyName"

            #Listboxes
            $UIHash.computerListbox = $MainWindow.FindName("computerListbox")
            $UIHash.computerListbox.DisplayMemberPath = "ComputerName"

            #ListViews
            $UIHash.ComputerListView = $MainWindow.FindName("ComputerListView")
            $UIHash.ListgridView = $MainWindow.FindName("ListViewGrid")
            $ListViewColumnHeaderProperties = "ComputerName","IPAddress","OperatingSystem","SerialNumber"

            $ListViewColumnHeaderProperties | foreach {
                $gridViewColumn = [System.Windows.Controls.GridViewColumn]::new()
                $gridViewColumn.Header = $_
                $Binding = [System.Windows.Data.Binding]::new($_)
                $Binding.Mode = [System.Windows.Data.BindingMode]::OneWay
                $gridViewColumn.DisplayMemberBinding = $Binding
                $UIHash.ListgridView.Columns.Add($gridViewColumn)
            }
            $UIHash.ComputerListView.View = $gridView

            #Checkboxes
            $UIHash.EnabledCheckBox = $MainWindow.FindName("LogCheckbox")

            #Slider
            $UIHash.TimeIntervalSlider = $MainWindow.FindName("timeIntervalTrack")
    
            $UIHash.MainWindow.ShowDialog()
        }
        catch{
            [System.Windows.MessageBox]::Show($_.Exception.Message)
            #Show-Messagebox -Text $_.Exception.Message
        }
    }
}