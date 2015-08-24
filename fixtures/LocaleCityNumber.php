<?php

$countryFile = file_get_contents('LocaleCountry.json');

$countries = json_decode($countryFile, true);
$countries = $countries['LocaleCountry']['data'];
$countryCodes = [];
foreach($countries as $c) {
    $countryCodes[$c['code']] = $c['name'];
}
//print_r($countryCodes);

$localesFile = file_get_contents('Locale.txt');
preg_match_all('#([a-z]{2})-([A-Z]{2})#', $localesFile, $localesMatches);

$localeLanguages = array_unique($localesMatches[1]);
$localeCountries = array_unique($localesMatches[2]);

foreach ($localeCountries as $c) {
    if (array_key_exists($c, $countryCodes) === false) {
        echo "Not found: $c" . PHP_EOL;
    }
}

$langFile = file_get_contents('LocaleLanguageName.json');
preg_match_all('#slug=([^"]*)"#', $langFile, $familyMatches);
$langJson = json_decode($langFile, true);
$langs = $langJson['LocaleLanguageName']['data'];
$langCodes = [];
foreach($langs as $l) {
    $langCodes[$l['code']] = $l['name'];
}
foreach ($localeLanguages as $l) {
    if (array_key_exists($l, $langCodes) === false) {
        echo "Not found: $c" . PHP_EOL;
    }
}

$famFile = file_get_contents('LocaleLanguageFamily.json');
$famJson = json_decode($famFile, true);
$fams = $famJson['LocaleLanguageFamily']['data'];
$famCodes = [];

foreach ($fams as $f) {
    $famCodes[$f['slug']] = $f['name'];
}

$famCodesFound = array_values(array_unique($familyMatches[1]));

foreach($famCodesFound as $f) {
    if (array_key_exists($f, $famCodes) === false) {
        echo "Not found: $f" . PHP_EOL;
    }
}

$cityFile = file_get_contents('LocaleCity.json');
$cityJson = json_decode($cityFile, true);
$cities = $cityJson['LocaleCity']['data'];
$cityCountry = [];
$cityLanguage = [];
$error = 0;
foreach($cities as $c) {
    if (array_key_exists('name', $c) === false || $error > 0) {
        print_r($c);
        $error++;
        if ($error == 1) {
            continue;
        }
    }
    $error = 0;
    $cityCountry[substr($c['country'], -2)] = $c['name'];
    $cityLanguage[substr($c['language'], -2)] = $c['name'];
}

foreach ($cityCountry as $code => $city) {
    if (array_key_exists($code, $countryCodes) === false) {
        echo "Not found (country) $code for city: $city" . PHP_EOL;
    }
}


die();
// DIE
//
//
//
//
//
//
//
//
// DIE

preg_match_all('#c"([a-z]{2})" a"([a-z]{3})"#', $langsFile, $langs);

$langA2 = $langs[1];
$langA3 = $langs[2];

echo "Creating Replacements..." . PHP_EOL;
for($i = 0; $i < count($langA2); $i++) {
    $langA2[$i] = 'code='.$langA2[$i];
}
//print_r($langA2);

echo "Creating Searches..." . PHP_EOL;
for($i = 0; $i < count($langA3); $i++) {
    $langA3[$i] = 'code='.$langA3[$i];
}
//print_r($langA3);
//die();

echo "Opening cities files..." . PHP_EOL;
$cityFile = file_get_contents('LocaleCity.yml');
$cityFileNew = $cityFile;

echo "Performing replacements: ";
$total = 0;
for($i=0; $i < count($langA3); $i++) {
    $count = 0;
    echo $langA3[$i] .'->'. $langA2[$i] .', ';
    $cityFileNew = str_ireplace($langA3[$i], $langA2[$i], $cityFileNew. $count);
    $total += $count;
}
echo PHP_EOL;

echo "Replaced $total instances..." . PHP_EOL;
//print_r($cityFileNew);

echo "Writing new file..." . PHP_EOL;
file_put_contents('LocaleCityNew.yml', $cityFileNew);

echo "Done..." . PHP_EOL;
/*$langsFile = file_get_contents('LocaleL');

preg_match_all('#c"([a-z]{2})" a"([a-z]{3})"#', $langsFile, $langs);

$langA2 = $langs[1];
$langA3 = $langs[2];

echo "Creating Replacements..." . PHP_EOL;
for($i = 0; $i < count($langA2); $i++) {
    $langA2[$i] = 'code='.$langA2[$i];
}
//print_r($langA2);

echo "Creating Searches..." . PHP_EOL;
for($i = 0; $i < count($langA3); $i++) {
    $langA3[$i] = 'code='.$langA3[$i];
}
//print_r($langA3);
//die();

echo "Opening cities files..." . PHP_EOL;
$cityFile = file_get_contents('LocaleCity.yml');
$cityFileNew = $cityFile;

echo "Performing replacements: ";
$total = 0;
for($i=0; $i < count($langA3); $i++) {
    $count = 0;
    echo $langA3[$i] .'->'. $langA2[$i] .', ';
    $cityFileNew = str_ireplace($langA3[$i], $langA2[$i], $cityFileNew. $count);
    $total += $count;
}
echo PHP_EOL;

echo "Replaced $total instances..." . PHP_EOL;
//print_r($cityFileNew);

echo "Writing new file..." . PHP_EOL;
file_put_contents('LocaleCityNew.yml', $cityFileNew);

echo "Done..." . PHP_EOL;
*/
