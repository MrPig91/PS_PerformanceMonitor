function Import-Xaml {
    param(
        $Path
    )
    Add-Type -AssemblyName PresentationFramework
    [xml]$xaml = Get-Content -Path $Path
    $manager = [System.Xml.XmlNamespaceManager]::new($xaml.NameTable)
    $manager.AddNamespace("x","http://schemas.microsoft.com/winfx/2006/xaml")
    $xamlReader = [System.Xml.XmlNodeReader]::new($xaml)
    [Windows.Markup.XamlReader]::Load($xamlReader)
}