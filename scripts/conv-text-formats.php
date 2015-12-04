#!/usr/bin/env php5
<?php

$usage = function () use ($argv, $argc) {
    echo 'Simple Format Converter (v0.5.0)'.PHP_EOL.PHP_EOL;
    echo 'Usage : '.$argv[0].' input_file_path[:input_type][:opt] [output_fil_path:]output_type[:opt]'.PHP_EOL.PHP_EOL;
    echo 'VALID INPUT/OUTPUT TYPES'.PHP_EOL;
    echo "\tj|json     : JavaScript Object Notation        [String]".PHP_EOL;
    echo "\ty|yml|yaml : YAML Ain't Markup Language        [String]".PHP_EOL;
    echo "\ti|igbinary : PHP Igbinary Module Serialization [Binary]".PHP_EOL;
    echo "\tp|phpserl  : PHP Internal Serialization        [String]".PHP_EOL;
    echo "\tc|csv      : Comma Separated Values            [String]".PHP_EOL.PHP_EOL;
    echo 'VALID OPT VALUES'.PHP_EOL;
    echo "\tno_header : Do not use first line of CVS as header values used as array index prior to output".PHP_EOL.
         "\t            handling when provided as option for input file section (only applicable to CSV).".PHP_EOL.
         "\t            When used as output opt, first-level array indexes are removed and integers used.".PHP_EOL.PHP_EOL;
    echo 'DESCRIPTION'.PHP_EOL;
    echo "\tUsing the minimum required arguments of an input file and output type, the following actions".PHP_EOL.
         "\twill occur to attempt to resolve the input type. First, it will try to use the extension of".PHP_EOL.
         "\tthe input file, which can be any of the aliases \"input_type\" accepts. If this fails, it will".PHP_EOL.
         "\trun through all available types until one does not fail, at which point it will confirm that".PHP_EOL.
         "\ta silent failure did not occur by encoding the result back to the same type and comparing it".PHP_EOL.
         "\twith the original input.".PHP_EOL.
         "\t   If an \"input_type\" is explicitly provided, it will use the appropriate method to handle".PHP_EOL.
         "\tthe passed type. In the event it cannot parse the input value with the requested type, it does".PHP_EOL.
         "\tnot perform the fallback routine used when an input type is not provided, but instead issues an".PHP_EOL.
         "\terror to STDERR.".PHP_EOL.
         "\t   If an output file path is provided, the resulting value is written to that file, overwriting".PHP_EOL.
         "\ta previous file if one exists. When not passed, the resulting value is written to STDOUT.".PHP_EOL.PHP_EOL;
    echo 'EXAMPLES'.PHP_EOL;
    echo "\t- YAML to JSON result will be sent to STDOUT:".PHP_EOL;
    echo "\t  # ".$argv[0].' /input/file.yaml json'.PHP_EOL.PHP_EOL;
    echo "\t- JSON (with strict type set) to PHP Serialized string will be sent to STDOUT:".PHP_EOL;
    echo "\t  # ".$argv[0].' /input/file.json:yaml phpserl'.PHP_EOL.PHP_EOL;
    echo "\t- YAML (with no type set explicitly) to CSV result will be sent to STDOUT (despite the wrong file ext):".PHP_EOL;
    echo "\t  # ".$argv[0].' /input/file.json csv'.PHP_EOL.PHP_EOL;
    echo "\t- Igbinary to YAML (with strict type set, using aliases) result will be sent to STDOUT:".PHP_EOL;
    echo "\t  # ".$argv[0].' /input/file:i y'.PHP_EOL.PHP_EOL;
    echo "\t- CSV to YAML (using input option) result will be written to output file:".PHP_EOL;
    echo "\t  # ".$argv[0].' /input/file:c:head /output/file:y'.PHP_EOL;
    die();
};

if ($argc !== 3) {
    $usage();
}

$canonicalizeTypes = [
    'json' => ['j', 'json'],
    'yaml' => ['y', 'yml', 'yaml'],
    'igbinary' => ['i', 'igbinary'],
    'phpserl' => ['p', 'phpserl'],
    'csv' => ['c', 'csv'],
];

$canonicalize = function ($typeAlias) use ($canonicalizeTypes, $usage) {
    foreach ($canonicalizeTypes as $type => $aliases) {
        if (in_array($typeAlias, $aliases)) {
            return $type;
        }
    }

    $usage();
};

$typeOpts = [
    'no_header' => ['json', 'yaml', 'igbinary', 'phpserl', 'cvs'],
];

$inputMethods = [
    'json' => function ($input) { return json_decode($input['file_string']); },
    'yaml' => function ($input) { return yaml_parse($input['file_string']); },
    'igbinary' => function ($input) { return igbinary_unserialize($input['file_string']); },
    'phpserl' => function ($input) { return unserialize($input['file_string']); },
    'csv' => function ($input) {
        $result = (array) array_map('str_getcsv', $input['file_lines']);
        $header = array_shift($result);
        $return = [];
        foreach ((array) $result as $i => $line) {
            $return[] = call_user_func(function () use ($line, $header) {
                $return = [];
                foreach ((array) $header as $i => $h) {
                    $h = is_string($h) ? trim($h) : $h;
                    if (empty($h)) {
                        $h = $i;
                    }
                    if (!array_key_exists($i, $line)) {
                        $l = null;
                    } else {
                        $l = is_string($line[$i]) ? trim($line[$i]) : $line[$i];
                    }

                    if (empty($l)) {
                        $l = null;
                    }

                    $return[$h] = $l;
                }

                return $return;
            });
        }

        return $return;
    },
];

$outputMethods = [
    'json' => function ($output) { return json_encode($output['input']); },
    'yaml' => function ($output) { return yaml_emit($output['input'], YAML_UTF8_ENCODING, YAML_LN_BREAK); },
    'igbinary' => function ($output) { return igbinary_serialize($output['input']); },
    'phpserl' => function ($output) { return serialize($output['input']); },
    'csv' => function ($output, $self) {
        $result = (array) $output['input'];
        if (count($result) === 0) {
            return '';
        }
        $stream = fopen('php://memory', 'w+');
        if (array_keys($result[0]) !== array_keys(array_values($result[0]))) {
            fputcsv($stream, array_keys($result[0]));
        }
        foreach ((array) $result as $line) {
            fputcsv($stream, $line);
        }
        rewind($stream);

        return stream_get_contents($stream);
    },
];

list($input, $output) = call_user_func(function () use ($argv, $argc, $canonicalizeTypes, $typeOpts, $usage, $canonicalize) {
    $inputP = explode(':', $argv[1]);
    $outputP = explode(':', $argv[2]);

    $input['file_path'] = realpath($inputP[0]);

    if (file_exists($input['file_path']) === false) {
        $usage();
    }

    $input = array_merge([
        'passed_cmd' => $argv[0],
        'file_lines' => file($input['file_path']),
        'file_string' => file_get_contents($input['file_path']),
    ], $input);

    if (count($inputP) === 2) {
        $input['type'] = $canonicalize($inputP[1]);
    } else {
        $input['type'] = $canonicalize(pathinfo($input['file_path'], PATHINFO_EXTENSION));
    }

    $output = [
        'passed_cmd' => $argv[1],
        'file_path' => pathinfo($input['file_path'], PATHINFO_DIRNAME).DIRECTORY_SEPARATOR.
                        pathinfo($input['file_path'], PATHINFO_FILENAME).'.'.$outputP[0],
        'type' => $outputP[0],
    ];

    return [$input, $output];
});

echo 'Reading: '.$input['file_path'].PHP_EOL;
$input['input'] = $inputMethods[$input['type']]($input, $inputMethods[$input['type']]);

echo 'Compiling output...'.PHP_EOL;
$output['result'] = $outputMethods[$output['type']]($input, $outputMethods[$output['type']]);

echo 'Writing: '.$output['file_path'].PHP_EOL;
file_put_contents($output['file_path'], $output['result']);
