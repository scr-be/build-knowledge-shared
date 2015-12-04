<?php

/*
 * This file is part of the Scribe Shared Public Knowledge Configuration.
 *
 * (c) Scribe Inc. <oss@scr.be>
 *
 * For the full copyright and license information, please view the LICENSE.md
 * file that was distributed with this source code.
 */

$excludes = ['Resources', 'Tests', 'config'];
$verbosity = 1;
$config = '%DIR_TMP%%DS%.sami-config.php';
$executables = [
    '%DIR_ROOT%%DS%bin%DS%sami.php',
    '%DIR_ROOT%%DS%vendor%DS%sami%DS%sami%DS%sami.php',
];

if (!isset($argv[1]) || false === ($projectRootPath = realpath($argv[1]))) {
    die('A valid project root path must be provided, got "'.(isset($argv[1]) ? $argv[1] : '<empty>').'".'.PHP_EOL);
}

$dirTmp = $projectRootPath.DIRECTORY_SEPARATOR.'build'.DIRECTORY_SEPARATOR.'.tmp-api';
$dirBld = $projectRootPath.DIRECTORY_SEPARATOR.'build'.DIRECTORY_SEPARATOR.'api';
$binary = null;
$cfgGen = ['<?php'];

if (!isset($argv[2]) || empty($projectName = $argv[2])) {
    die('A project name must be provided as the second argument argument, got "'.(isset($argv[2]) ? $argv[2] : '<empty>').'".'.PHP_EOL);
}

$atb = function (...$b) use (&$cfgGen) {
    if (count($b) > 0 && is_array($b)) {
        foreach ($b as $line) {
            $cfgGen[] = $line;
        }
    }

    return (array) $cfgGen;
};

$replaceDirectoryPlaceholders = function ($path) use ($projectRootPath, $dirTmp, $dirBld) {
    $path = str_replace('%DIR_ROOT%', $projectRootPath, $path);
    $path = str_replace('%DIR_TMP%', $dirTmp, $path);
    $path = str_replace('%DIR_BUILD%', $dirBld, $path);
    $path = str_replace('%DS%', DIRECTORY_SEPARATOR, $path);

    return $path;
};

$out = function ($string) use ($verbosity) {
    if ($verbosity > 0) {
        echo $string;
    }
};

$removeDirectoryRecursive = function ($dir) use (&$removeDirectoryRecursive) {
    if (false === ($dir = realpath($dir))) {
        return true;
    }

    $files = array_diff(scandir($dir), ['.', '..']);
    foreach ($files as $f) {
        (is_dir($dir.DIRECTORY_SEPARATOR.$f)) ? $removeDirectoryRecursive($dir.DIRECTORY_SEPARATOR.$f) : unlink($dir.DIRECTORY_SEPARATOR.$f);
    }

    return rmdir($dir);
};

$removeAndMakeDirectory = function ($dir, $mode = 0777) use ($removeDirectoryRecursive, $out) {
    if (false === $removeDirectoryRecursive($dir)) {
        $out("  - [EXIT] Cannot delete dir '$dir'".PHP_EOL);
        exit;
    }

    @mkdir($dir, $mode, true);
    if (!is_dir($dir)) {
        exit;
    }

    $out("  - [okay] '$dir'".PHP_EOL);
};

$promptYesNo = function ($prompt, $default = true, $exit = false) use ($out) {
    $exitNow = function ($string, $code = -1) use ($out) {
        $out(PHP_EOL.$string.PHP_EOL.PHP_EOL);
        exit($code);
    };

    $retYes = function () use ($out) {
        $out("+++ Response interpreted as 'YES'".PHP_EOL.PHP_EOL);

        return true;
    };

    $retNo = function () use ($exitNow, $exit, $out) {
        $out("!!! Response interpreted as 'NO'".PHP_EOL);

        if ($exit !== false) {
            $exitNow($exit);
        }

        return false;
    };

    $responses_yes = ['yes', 'y'];
    $responses_no = ['no',  'n'];

    $prompt = '>>> '.$prompt.' '.($default ? '[Y/n]' : '[y/N]').': ';

    while (true) {
        $out($prompt);
        $response = strtolower(chop(fgets(STDIN)));

        if ($response == '' && $default === false && $exit !== false) {
            $exitNow($exit);
        }

        if ($response == '') {
            return (bool) (true === $default ? $retYes() : $retNo());
        }

        if (true === in_array($response, $responses_yes)) {
            return (bool) $retYes();
        }

        if (true === in_array($response, $responses_no)) {
            return (bool) $retNo();
        }

        $out("!!! Invalid response of '$response' provided.".PHP_EOL);
    }
};

require $replaceDirectoryPlaceholders('%DIR_ROOT%%DS%vendor%DS%autoload.php');

use Sami\Sami;
use Symfony\Component\Finder\Finder;
use Symfony\Component\Process\Exception\ProcessFailedException;
use Symfony\Component\Process\Process;

array_walk($executables, function (&$val) use ($replaceDirectoryPlaceholders) {
    $val = $replaceDirectoryPlaceholders($val);
});

foreach ($executables as $e) {
    if (false !== ($e = realpath($e))) {
        $binary = $e;
        break;
    }
}

if ($binary === null) {
    die('A suitable Sami binary could not be found in configured paths: '.implode(', ', $executables));
}

$atb(
    PHP_EOL,
    'use Sami\Sami;',
    'use Symfony\Component\Finder\Finder;',
    PHP_EOL
);

$out('SAMI CONFIG RUNNER'.PHP_EOL.'by Rob Frawley 2nd <rmf@scr.be>'.PHP_EOL.PHP_EOL);
$out('Initializing:'.PHP_EOL);
$out("  - [info] Project Name  : $projectName".PHP_EOL);
$out("  - [info] Base Path     : $projectRootPath".PHP_EOL);
$out("  - [info] Build Path    : $dirTmp".PHP_EOL);
$out("  - [info] Output Path   : $dirBld".PHP_EOL);
$out("  - [info] Sami          : $binary".PHP_EOL);
$out('  - [info] Output Config : '.($config = $replaceDirectoryPlaceholders($config)).PHP_EOL.PHP_EOL);

$iterator = Finder::create()->files()->name('*.php');
$atb(
    '$iterator = Finder::create()',
    '    ->files()',
    '    ->name(\'*.php\')'
);

if (count($excludes) > 0) {
    $out('Exclude patterns:'.PHP_EOL);

    foreach ($excludes as $e) {
        $out("  - [okay] '$e'".PHP_EOL);

        $iterator->exclude($e);
        $atb('    ->exclude("'.$e.'")');
    }

    $out(PHP_EOL);
}

$out('Including dirs:'.PHP_EOL);
$resolvedPathCount = 0;

if ($argc > 3) {
    for ($i = 3; $i < $argc; ++$i) {
        $resolvedPath = $projectRootPath.DIRECTORY_SEPARATOR.$argv[$i];

        if (false === ($resolvedPath = realpath($resolvedPath))) {
            $out("  - [SKIP] '".$projectRootPath.DIRECTORY_SEPARATOR.$argv[$i]."'".PHP_EOL);
            continue;
        }

        ++$resolvedPathCount;
        $out("  - [okay] '$resolvedPath'".PHP_EOL);

        $iterator->in($resolvedPath);
        $atb('    ->in("'.$resolvedPath.'")');
    }
} else {
    foreach (['src', 'lib'] as $defaultDir) {
        $resolvedPath = $replaceDirectoryPlaceholders('%DIR_ROOT%%DS%'.$defaultDir);

        if (!empty($resolvedPath) && false !== ($resolvedPath = realpath($resolvedPath))) {
            ++$resolvedPathCount;
            $out("  - [okay] '$resolvedPath' (default)".PHP_EOL);

            $iterator->in($resolvedPath);
            $atb('    ->in("'.$resolvedPath.'")');
        }
    }
}

if (true !== ($resolvedPathCount > 0)) {
    $out('  - [EXIT] No included paths configured.'.PHP_EOL);
    exit;
} else {
    $atb(';', PHP_EOL);
    $out(PHP_EOL);
}

$promptYesNo('Continue using the show configuration?', true, 'Execution canceled via user input.');

$out('Removing and re-created dirs:'.PHP_EOL);
$removeAndMakeDirectory($dirTmp);
$removeAndMakeDirectory($dirBld);
$out(PHP_EOL);

$atb(
    'return new Sami($iterator, [',
    "  'theme'                => 'default',",
    "  'title'                => '".$projectName.'\',',
    "  'build_dir'            => '".$dirBld.'\',',
    "  'cache_dir'            => '".$dirTmp.'\',',
    "  'default_opened_level' => 3",
    ']);',
    PHP_EOL
);

$out("Writing Sami config to '$config'".PHP_EOL.PHP_EOL);
file_put_contents($config, implode(PHP_EOL, $atb()));

$out('Processing...');
try {
    $cmd = sprintf('%s update %s', $binary, $config);

    $process = new Process($cmd);
    $process->mustRun();
} catch (ProcessFailedException $e) {
    die("An error occured while processing with '$cmd': ".$e->getMessage());
}

$out('done.'.PHP_EOL.PHP_EOL);
$out('Removing temp dirs:'.PHP_EOL);
$removeAndMakeDirectory($dirTmp);
$out(PHP_EOL);

$out('Complete!'.PHP_EOL.PHP_EOL);

/* EOF */
