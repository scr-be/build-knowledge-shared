#!/usr/bin/env php
<?php

function ask($what, $default = null, \Closure $validator = null)
{
	while (true) {
		echo $what;

		if ($default) {
			echo ' [' . $default . ']';
		}

		echo ': ';

		$stdin = fopen ("php://stdin","r");
		$input = trim(fgets($stdin));

		if (!($validator instanceof \Closure)) {
			$validator = $default === null
				? 
				function($in) {
					if (strlen($in) === 0) {
						return false;
					}

					return $in;
				}
				:
				function($in, $default) {
					if (strlen($in) === 0) {
						return $default;
					}

					return $in;
				};
		}

		if (false !== ($return = $validator($input, $default))) {
			break;
		}

		echo "Error: Your entry was invalid." . PHP_EOL;
	}

	return $return;
}

function bundleClass($pkg)
{
	$parts = array_merge(['Scribe'], explode('-', $pkg));

	$parts = array_map(function($v) {
		return ucfirst(strtolower($v));
	}, $parts);

	$class = implode('', $parts);	

	$ns = '';
	for ($i = 0; $i < count($parts); ++$i) {
		if ($i < 2) {
			$ns .= $parts[$i] . '\\';
			continue;
		}
		$ns .= $parts[$i];
	}

	$binParts = $parts;
	$cfgParts = $parts;
	array_shift($binParts);
	array_pop($binParts);
	array_pop($cfgParts);

	$bin = 'bin/' . strtolower(implode('-', $binParts));
	$cfg = strtolower(implode('_', $cfgParts));

	return [
		$ns,
		$class,
		$bin,
		$cfg,
		$parts[1],
	];
}

function groupDesc($group)
{
	$descs = [
		'teavee' => 'media, HTML, content, generator',
	];

	if (array_key_exists($group, $descs)) {
		return $descs[$group];
	}

	return null;
}

$tpl = file_get_contents(__DIR__ . DIRECTORY_SEPARATOR . 'tpl-readme-bundle.md');
$descValidator = function($in, $default) {
	if (strlen($in) === 0) {
		$in = $default;
	}

	return str_replace('\\n', PHP_EOL, $in);
};

$dotPkgData['pkg_name'] = null;
$dotPkgData['pkg_desc'] = null;
$dotPkg = realpath(getcwd() . DIRECTORY_SEPARATOR . '.package.yml');

if (file_exists($dotPkg)) {
	$dotPkgDataRaw = file_get_contents($dotPkg);
	$dotPkgDataLines = explode(PHP_EOL, $dotPkgDataRaw);
	$dotPkgDataNorm = [];

	foreach ($dotPkgDataLines as $line) {
		$dotPos = strpos($line, ':');
		$dotKey = trim(substr($line, 0, $dotPos));
		$dotVal = trim(substr($line, $dotPos + 1));
		$dotVal = preg_replace('{^"}', '', $dotVal);
		$dotVal = preg_replace('{"$}', '', $dotVal);

		if (array_key_exists($dotKey, $dotPkgData)) {
			$dotPkgData[$dotKey] = $dotVal;
		}
	}
}

$rpl['package'] = ask('Name', $dotPkgData['pkg_name']);
$rpl['desc'] = ask('Description', $dotPkgData['pkg_desc'], $descValidator);
$rpl['group'] = ask('Group', substr($rpl['package'], 0, strpos($rpl['package'], '-')));
$rpl['group-desc'] = ask('Group Description', groupDesc($rpl['group']));
$rpl['bundle'] = ask('Bundle Class', bundleClass($rpl['package'])[1]);
$rpl['ns'] = ask('Bundle Namespace', bundleClass($rpl['package'])[0]);
$rpl['bin'] = ask('Console Bin', bundleClass($rpl['package'])[2]);
$rpl['config-dump'] = ask('Config Key', bundleClass($rpl['package'])[3]);
$out = ask('Output File', realpath(getcwd()) . DIRECTORY_SEPARATOR . 'README.md');

foreach ($rpl as $search => $replace) {
	$tpl = str_replace('%' . $search . '%', $replace, $tpl);
}

file_put_contents($out, $tpl);

echo "Wrote README." . PHP_EOL;
