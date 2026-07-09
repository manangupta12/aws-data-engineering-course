$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)

$sampleFile = Join-Path $PWD "data\sample.txt"
$hdfsPath = "/user/root/input/sample.txt"
$outputPath = "/user/root/output/wordcount"

if (-not (Test-Path $sampleFile)) {
    Write-Error "Missing sample file: $sampleFile"
}

Write-Host "Waiting for cluster health..."
for ($i = 0; $i -lt 60; $i++) {
    $status = docker inspect --format='{{.State.Health.Status}}' namenode 2>$null
    if ($status -eq "healthy") { break }
    Start-Sleep -Seconds 5
}

Write-Host "Creating HDFS directory..."
docker exec namenode hdfs dfs -mkdir -p /user/root/input

Write-Host "Uploading sample file to HDFS..."
Get-Content $sampleFile -Raw | docker exec -i namenode hdfs dfs -put -f - $hdfsPath

Write-Host "Listing HDFS path..."
docker exec namenode hdfs dfs -ls /user/root/input

Write-Host "Reading file from HDFS..."
docker exec namenode hdfs dfs -cat $hdfsPath

Write-Host ""
Write-Host "Running wordcount MapReduce job..."
docker exec namenode bash -lc "hadoop jar `$(ls `$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar | head -1) wordcount $hdfsPath $outputPath"

Write-Host "Wordcount output:"
docker exec namenode hdfs dfs -cat "$outputPath/part-r-00000"

Write-Host ""
Write-Host "Smoke test passed."
