﻿# -----------------------------------------------
# Xdt Config Transform
# -----------------------------------------------
#
# Ver   Who                     When      What
# 1.0   Evolve Software Ltd     14-05-16  Initial Version

# Script Input Parameters
param (
    [ValidateNotNullOrEmpty()]
    [string] $ConfigurationFile = $(throw "-ConfigurationFile is mandatory, please provide a value."),
    [ValidateNotNullOrEmpty()]
    [string] $TransformFile = $(throw "-TransformFile is mandatory, please provide a value."),
    [ValidateNotNullOrEmpty()]
    [string] $LibraryPath = $(throw "-LibraryPath is mandatory, please provide a value.")
)

function Main() 
{
    $CurrentScriptVersion = "1.0"

    Write-Host "================== Xdt Config Transform - Version"$CurrentScriptVersion": START =================="

    # Log input variables passed in
    Log-Variables
    Write-Host

    if (!$ConfigurationFile -or !(Test-Path -path $ConfigurationFile -PathType Leaf)) {
        throw "File not found. $ConfigurationFile";
        Exit 1
    }
    if (!$TransformFile -or !(Test-Path -path $TransformFile -PathType Leaf)) {
        throw "File not found. $TransformFile";
        Exit 1
    }

    try {

        Add-Type -LiteralPath "$LibraryPath\Microsoft.Web.XmlTransform.dll"
        $xml = New-Object Microsoft.Web.XmlTransform.XmlTransformableDocument;
        $xml.PreserveWhitespace = $true
        $xml.Load($ConfigurationFile);

        $xmlTransform = New-Object Microsoft.Web.XmlTransform.XmlTransformation($TransformFile);
        if ($xmlTransform.Apply($xml) -eq $false)
        {
            throw "Transformation failed."
        }
        $xml.Save($ConfigurationFile)
    } 
    catch [System.Exception] {
        Write-Output $_
        Exit 1
    }

    Write-Host "================== Xdt Config Transform - Version"$CurrentScriptVersion": END =================="
}

function Log-Variables
{
    Write-Host "ConfigurationFile: " $ConfigurationFile
    Write-Host "TransformFile: " $TransformFile
    Write-Host "LibraryPath: " $LibraryPath
    Write-Host "Computername:" (gc env:computername)
}

Main
