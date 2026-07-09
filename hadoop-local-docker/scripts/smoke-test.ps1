$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)
. (Join-Path $PSScriptRoot "lib.ps1")

$sampleFile = Join-Path $PWD "data\sample.txt"
$hdfsPath = "/user/root/input/sample.txt"
$outputPath = "/user/root/output/wordcount"

Require-Docker

if (-not (Test-Path $sampleFile)) {
    throw "Missing sample file: $sampleFile"
}

Wait-ForCluster -TimeoutSeconds 300

Write-Host "Creating HDFS directory..."
docker exec namenode hdfs dfs -mkdir -p /user/root/input

Write-Host "Uploading sample file to HDFS..."
docker cp $sampleFile namenode:/tmp/sample.txt
docker exec namenode hdfs dfs -put -f /tmp/sample.txt $hdfsPath

Write-Host "Listing HDFS path..."
docker exec namenode hdfs dfs -ls /user/root/input

Write-Host "Reading file from HDFS..."
docker exec namenode hdfs dfs -cat $hdfsPath

Write-Host ""
Write-Host "Running wordcount MapReduce job..."
docker exec namenode hdfs dfs -rm -r -f $outputPath 2>$null | Out-Null
docker exec namenode bash -lc "hadoop jar `$(ls `$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar | head -1) wordcount $hdfsPath $outputPath"

Write-Host "Wordcount output:"
docker exec namenode hdfs dfs -cat "$outputPath/part-r-00000"

Write-Host ""
Write-Host "Smoke test passed."
