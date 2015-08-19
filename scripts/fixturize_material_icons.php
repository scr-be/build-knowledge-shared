<?php

$files = [
    __DIR__ . '/../../vendor/autoload.php',
    __DIR__ . '/../../../vendor/autoload.php',
    __DIR__ . '/../../../../vendor/autoload.php',
    __DIR__ . '/../../../../../vendor/autoload.php'
];

foreach ($files as $file) {
    if (file_exists($file)) {
        include_once $file;

        define('PHP_COVERALLS_COMPOSER_INSTALL', $file);

        break;
    }
}

if (!defined('PHP_COVERALLS_COMPOSER_INSTALL')) {
    die(
        'You need to set up the project dependencies using the following commands:' . PHP_EOL .
        'curl -s http://getcomposer.org/installer | php' . PHP_EOL .
        'php composer.phar install' . PHP_EOL
    );
}

use Symfony\Component\Yaml\Yaml;
use Symfony\Component\Finder\Shell\Command;

function getLatestRepoSource()
{
    $workingDir = '/tmp/';
    $materialDir = '/tmp/material-design-icons';

    chdir($workingDir);

    if (false === is_dir($materialDir)) {
        Command::create()->cmd('git clone git@github.com:google/material-design-icons.git '.$materialDir)->execute();
    }

    if (false === is_dir($materialDir)) {
        die('Could not enter '.$materialDir);
    }

    chdir($materialDir);
    Command::create()->cmd('git fetch')->execute();
    Command::create()->cmd('git checkout master')->execute();
    Command::create()->cmd('git pull')->execute();
}

function filePathToCategory($path)
{
    $path = str_replace('/ios/ic_zoom_in_white_36pt.imageset/Contents.json', '', $path);

    return $path;
}

function readSpritesIntoArray()
{
    $spriteFileList = glob('*/ios/*_white.imageset/Contents.json');
    $spriteFileContents = [];

    foreach ($spriteFileList as $file) {
        $spriteFileContents[filePathToCategory($file)] = file_get_contents($file);
    }

    return $spriteFileContents;
}

function findCategoriesFromIcon($name, $sprites)
{
    $categoryCollection = [];

    foreach ($sprites as $category => $spriteContent) {
        if (false !== strpos($spriteContent, 'ic_'.$name.'_white')) {
            $categoryHuman = explode('/', $category)[0];
            $categoryCollection[] = ucwords($categoryHuman);
        }
    }

    if (count($categoryCollection) === 0) {
        die('Could not determine category for '.$name);
    }

    return $categoryCollection;
}

function resolveIconObjects($sprites)
{
    $webCodePointsFileContents = file('./iconfont/codepoints', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    $webCodePoints = [];

    foreach ($webCodePointsFileContents as $wcp) {
        $wcpParts = explode(' ', $wcp);
        list($slug, $unicode) = $wcpParts;

        $webCodePoint = [
            'slug' => null,
            'name' => null,
            'unicode' => null,
            'aliases' => null,
            'categories' => null,
            'attributes' => null,
            'families' => ['@IconFamily?slug=md', '@IconFamily?slug=mdb']
        ];

        $name = ucwords(str_replace('_', ' ', $slug));
        $name = strlen($name) < 3 ? strtoupper($name) : ucwords($name);
        $categories = findCategoriesFromIcon($slug, $sprites);
        $aliases = [str_replace('_', '-', $slug)];

        if ($aliases !== null && count($aliases) > 0 && $aliases[0] == $slug) { $aliases = null; }

        $webCodePoint['name'] = $name;
        $webCodePoint['slug'] = $slug;
        $webCodePoint['unicode'] = $unicode;
        $webCodePoint['categories'] = $categories;
        $webCodePoint['aliases'] = $aliases;

        $webCodePoints[] = $webCodePoint;
    }

    return $webCodePoints;
}

function main()
{
    getLatestRepoSource();
    $sprites = readSpritesIntoArray();
    $icons = resolveIconObjects($sprites);
    $yaml = Yaml::dump($icons, 10, 4);
    echo $yaml;
}

main();
