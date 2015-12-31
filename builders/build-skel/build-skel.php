#!/usr/bin/env php
<?php

function ask($what, $default = null, \Closure $validator = null)
{
	while (true) {
		echo PHP_EOL . ' >> ' . $what;

		if ($default) {
			echo ' [ ' . $default . ' ] : ';
		} else {
			echo ' [ <none> ] : ';
		}

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

		outWarning('Your entry was invalid; please try again.', 'BAD INPUT');
	}

	return $return;
}

function outLines(array $lines, $prefix = null)
{
	$prefix = ($prefix === null ? '  ' : $prefix) . ' ';

	foreach ($lines as $l) {
		if ($l === null) {
			echo PHP_EOL;
			continue;
		}

		echo ' ' . $prefix . $l . PHP_EOL;
	}

	echo PHP_EOL;
}

function outOpener($lines)
{
	outLines(array_merge([null, ''], (array) $lines, ['', null]), '||');
}

function outWarning($lines, $title = 'WARNING')
{
	outLines(array_merge([null, ''], (array) $title, [''], (array) $lines, ['', null]), '!!');
}

function outSection($lines, $title = 'SECTION')
{
	outLines(array_merge([''], (array) $title, [''], (array) $lines, ['']), '##');
}

function outInfo($lines)
{
	outLines(array_merge([''], (array) $lines, ['']), '--');
}

function getPackageInfoParts($pkg)
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

function groupDesc($group, $attributes)
{
	$groupAttributes = $attributes['groups'];

	if (array_key_exists($group, $groupAttributes)) {
		return $groupAttributes[$group]['description'];
	}

	return null;
}

function getAttributes($attributesFilePath)
{
	outInfo('Reading in attributes: '.$attributesFilePath);

	return json_decode(file_get_contents($attributesFilePath), true);
}

function getPackageCfg($packageCfgFilePath, $packageCfg)
{
	outInfo('Reading in package config: '.$packageCfgFilePath);

	$fileLines = explode(PHP_EOL, file_get_contents($packageCfgFilePath));

	foreach ($fileLines as $line) {
		$linePosition = strpos($line, ':');
		$lineVariable = trim(substr($line, 0, $linePosition));
		$lineValue    = trim(substr($line, $linePosition + 1));
		$lineValue    = preg_replace('{^"}', '', $lineValue);
		$lineValue    = preg_replace('{"$}', '', $lineValue);

		if (array_key_exists($lineVariable, $packageCfg)) {
			$packageCfg[$lineVariable] = $lineValue;
		}
	}

	return $packageCfg;
}

function getFileInfoModeSpecific($file, $isBndlMode, $attributes)
{
	if ($isBndlMode) {
		$fileInfo = $attributes['tpls']['bdl'][$file];
	} else {
		$fileInfo = $attributes['tpls']['lib'][$file];
	}

	if (!array_key_exists('from', $fileInfo) || !array_key_exists('dest', $fileInfo)) {
		outError('Invalid attributes config for '.$file);
		doExit();
	}

	if (!array_key_exists('mode', $fileInfo)) {
		$fileInfo['mode'] = 'link';
	}

	if (!($realPath = realpath(__DIR__ . DIRECTORY_SEPARATOR . $fileInfo['from'])) || !file_exists($realPath)) {
		outError('Could not read template: %s', $fileInfo['from']);
		doExit();
	}

	return $fileInfo;
}

function assignReadMeFilePath($isBndlMode, $attributes, &$copyFiles, &$linkFiles)
{
	$file = getFileInfoModeSpecific('readme', $isBndlMode, $attributes);
	$fileOp = [$file['dest'] => $file['from']];

	if ($file['mode'] === 'link') {
		$linkFiles = array_merge($linkFiles, (array) $fileOp);
	} else {
		$copyFiles = array_merge($copyFiles, (array) $fileOp);
	}
}

function assignPhpUnitFilePath($isBndlMode, $attributes, &$copyFiles, &$linkFiles)
{
	$file = getFileInfoModeSpecific('phpunit', $isBndlMode, $attributes);
	$fileOp = [$file['dest'] => $file['from']];

	if ($file['mode'] === 'link') {
		$linkFiles = array_merge($linkFiles, (array) $fileOp);
	} else {
		$copyFiles = array_merge($copyFiles, (array) $fileOp);
	}
}

function assignOtherFilePaths($attributes, &$copyFiles, &$linkFiles)
{
	$getFilesOfType = function($which) use ($attributes) {
		return $attributes['tpls'][$which];
	};

	$validateAndNormalizeFiles = function(array $files) {
		array_map(function ($from) {
			if (!($realPath = realpath(__DIR__ . DIRECTORY_SEPARATOR . $from)) || !file_exists($realPath)) {
				outError('Could not read file template: %s', $from);
				doExit();
			}
		}, array_keys($files));

		return array_combine(array_values($files), array_keys($files));
	};

	$copyFiles = array_merge($copyFiles, $validateAndNormalizeFiles($getFilesOfType('copy')));
	$linkFiles = array_merge($linkFiles, $validateAndNormalizeFiles($getFilesOfType('link')));
}

function normalizeFilePaths(array $collections)
{
	$normalized = [];

	foreach ($collections as $i => $c) {
		if (!isset($normalized[$i])) {
			$normalized[$i] = [];
		}

		foreach ($c as $j => $f) {
			$normalized[$i][getcwd() . DIRECTORY_SEPARATOR . $j] = realpath(__DIR__ . DIRECTORY_SEPARATOR . $f);
		}
	}

	return $normalized;
}

function getAllFilePaths($isBndlMode, $attributes)
{
	$files = $copyFiles = $linkFiles = [];

	assignReadMeFilePath($isBndlMode, $attributes, $copyFiles, $linkFiles);
	assignPhpUnitFilePath($isBndlMode, $attributes, $copyFiles, $linkFiles);
	assignOtherFilePaths($attributes, $copyFiles, $linkFiles);

	list($copyFiles, $linkFiles) = normalizeFilePaths([$copyFiles, $linkFiles]);

	$files = array_merge(
		(array) $copyFiles,
		(array) $linkFiles
	);

	return [$files, $copyFiles, $linkFiles];
}

function getFileContentsReplaced($files, $replacements)
{
	$fileContents = [];

	foreach ($files as $i => $f) {
		$c = file_get_contents($f);

		foreach ($replacements as $search => $replace) {
			$c = str_replace('%' . $search . '%', $replace, $c);
		}

		$fileContents[$i] = $c;
	}

	return $fileContents;
}

function getFileOperations($isBndlMode, $packageCfg, $attributes)
{
	list($files, $copyFiles, $linkFiles) = getAllFilePaths($isBndlMode, $attributes);

	outSection([
		'Enter the requested information about the package to allow for skeleton auto-generation.',
		'If a default value is shown it can be used by not entering a new value.',
	], 'Configuration');

	$r['package'] = ask('Package Name', $packageCfg['pkg_name']);
	$r['desc']    = ask('Short Desc', $packageCfg['pkg_desc'], function($in, $default) {
		if (strlen($in) === 0) {
			$in = $default;
		}
		return str_replace('\\n', PHP_EOL, $in);
	});
	$r['group']      = ask('Group Name', substr($r['package'], 0, strpos($r['package'], '-')));
	$r['group-desc'] = ask('Group Concentration', groupDesc($r['group'], $attributes));

	if ($isBndlMode) {
		$r['bundle']      = ask('Bundle Classname', getPackageInfoParts($r['package'])[1]);
		$r['ns']          = ask('Bundle Namespace', getPackageInfoParts($r['package'])[0]);
		$r['bin']         = ask('Console Bin Path', getPackageInfoParts($r['package'])[2]);
		$r['config-dump'] = ask('Config Root Tree Name', getPackageInfoParts($r['package'])[3]);
	}

	outLines([null, null]);

	$copyFileContents = getFileContentsReplaced($copyFiles, $r);

	return [$files, $linkFiles, $copyFiles, $copyFileContents];
}

function performLinkOperations($files)
{
	outSection(['Writing out symbolic links.']);

	$cwd = getcwd() . DIRECTORY_SEPARATOR;

	foreach ($files as $dest => $from) {
		$fileDest = str_replace($cwd, '', $dest);
		$fileFrom = str_replace($cwd, '', $from);

		$cmd = 'rm -fr ' . escapeshellarg($dest) . '; ln -s ' . escapeshellarg($fileFrom) . ' ' . escapeshellarg($fileDest);

		outInfo('Writing link: ' . $fileDest . ' -> ' . $fileFrom);

		exec($cmd);
	}
}

function performCopyOperations($files, $contents)
{
	outSection(['Writing out new files.']);

	$cwd = getcwd() . DIRECTORY_SEPARATOR;

	foreach ($files as $dest => $from) {
		if (!array_key_exists($dest, $contents)) {
			continue;
		}

		$fileDest = str_replace($cwd, '', $dest);

		outInfo('Writing new file: ' . $fileDest);

		file_put_contents($fileDest, $contents[$dest]);
	}
}

function main()
{
	outOpener([
		'Build Package Skeleton (v1.0.0)',
		'',
		'Author    : Rob Frawley 2nd <rmf@src.run>',
		'License   : MIT License',
		'Copyright : (c) 2016 Rob Frawley 2nd',
	]);

	$attributesFilePath = realpath(__DIR__ . DIRECTORY_SEPARATOR . '.build-skel-config' . DIRECTORY_SEPARATOR . 'attributes.json');
	$packageCfgFilePath = realpath(getcwd() . DIRECTORY_SEPARATOR . '.package.yml');
	$packageCfg         = [ 'pkg_name' => null, 'pkg_desc' => null, 'pkg_bndl' => false];

	if (!file_exists($attributesFilePath)) {
		die('Unable to find attributes config file: attributes.json');
	} elseif (!file_exists($packageCfgFilePath)) {
		die('Unable to find package config file: .package.yml');
	}

	$attributes = getAttributes($attributesFilePath);
	$packageCfg = getPackageCfg($packageCfgFilePath, $packageCfg);
	$isBndlMode = (bool) ($packageCfg['pkg_bndl'] === "true");

	outInfo('Setting runtime mode: '.($isBndlMode ? 'BUNDLE' : 'LIBRARY'));

	list($files, $linkFiles, $copyFiles, $copyFileContents) = getFileOperations($isBndlMode, $packageCfg, $attributes);

	performLinkOperations($linkFiles);
	performCopyOperations($copyFiles, $copyFileContents);
}

main();
