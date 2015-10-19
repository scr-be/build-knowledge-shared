<?php

function usage($argv) {
    echo "Usage: $argv[0] file_name search_str [start_int] [add_int]" . PHP_EOL;
    die();
}

if ($argc < 3) {
    usage($argv);
}

$fileName  = (string) $argv[1];
$strNeedle = (string) $argv[2];
$needleLen = (int)    strlen($strNeedle);
$intStart  = (int)    (array_key_exists(3, $argv) ? $argv[3] : 1);
$intIterA  = (int)    (array_key_exists(4, $argv) ? $argv[4] : 1);

if (is_readable($fileName) !== true) {
    die("Could not read provided file \"$fileName\" - exiting.".PHP_EOL);
}

echo "Reading file $fileName..." . PHP_EOL;
$fileContents = file_get_contents($fileName);

echo "Performing replacements.";
$i = $intStart;
while(true) {
    if (($strPosition = strpos($fileContents, $strNeedle)) === false) { break; }

    $fileContents = substr_replace($fileContents, $i, $strPosition, $needleLen);

    if ($i % 10000 == 0) { echo '0'; } elseif ($i % 1000 == 0) { echo 'o'; } elseif ($i % 100 == 0) { echo '.'; }

    $i = $i + $intIterA;
}

echo "Writing file $fileName.out..." . PHP_EOL;

file_put_contents($fileName.'.out', $fileContents);

echo "Done!" . PHP_EOL;
