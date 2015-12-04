<?php
/*
 * This file is part of the Scribe Mantle Bundle.
 *
 * (c) Scribe Inc. <source@scribe.software>
 *
 * For the full copyright and license information, please view the LICENSE.md
 * file that was distributed with this source code.
 */

require_once realpath(__DIR__.'/constants.php');

/**
 * Create new LogicException instance.
 *
 * @param string   $message       The error message (passed to sprintf)
 * @param ...mixed $substitutions The message substitutions (passed to sprintf)
 *
 * @return \LogicException
 */
function testBootstrap__newLogicException($message, ...$substitutions)
{
    return new \LogicException(
        call_user_func_array('sprintf', array_merge((array) $message, (array) $substitutions))
    );
}

/**
 * Throw an exception for an unrecoverable error.
 *
 * @param string   $message       The error message (passed to sprintf)
 * @param ...mixed $substitutions The message substitutions (passed to sprintf)
 *
 * @throws \LogicException
 */
function testBootstrap__fatalError($message, ...$substitutions)
{
    throw testBootstrap__newLogicException($message, ...$substitutions);
}

/**
 * Handle an error that (may be) recoverable by displaying the message
 * and attempting to continue.
 *
 * @param string   $message       The error message (passed to sprintf)
 * @param ...mixed $substitutions The message substitutions (passed to sprintf)
 *
 * @return bool
 */
function testBootstrap__recoverableError($message, ...$substitutions)
{
    try {
        testBootstrap__fatalError($message, ...$substitutions);
    } catch (\LogicException $e) {
        sprintf('Error Message: %s. Attempting to continue.', $e->getMessage());
    }

    return false;
}

/**
 * Attempt to include a file if it exists.
 *
 * @param string               $filePath  File path to include
 * @param \LogicException|null $exception Optional exception to throw on error, otherwise
 *                                        return false if null
 *
 * @throws \LogicException|\Exception
 *
 * @return bool|mixed
 */
function testBootstrap__includeFileOnce($filePath, \LogicException $exception = null)
{
    $filePath = realpath($filePath);

    if (file_exists($filePath) !== true) {
        if ($exception === null) {
            return false;
        } else {
            throw $exception;
        }
    }

    return include_once $filePath;
}

/**
 * Attempt to include a file if it exists.
 *
 * @param string               $filePath  File path to include
 * @param \LogicException|null $exception Exception to throw if file is not found
 *
 * @return bool|mixed
 */
function testBootstrap__requireFileOnce($filePath, \LogicException $exception)
{
    return testBootstrap__includeFileOnce($filePath, $exception);
}

/**
 * Remove directory if it exists.
 *
 * @param string $path       Path to remove.
 * @param bool   $removeBase Should the passed base dir be removed.
 *
 * @return bool
 */
function testBootstrap__removeDirectory($path, $removeBase = false)
{
    if (false === is_dir($path)) {
        return false;
    }

    foreach ((array) glob($path.'/*') as $file) {
        is_dir($file) ? testBootstrap__removeDirectory($file) : unlink($file);
    }

    if (true === $removeBase) {
        rmdir($path);
    }

    return true;
}

/**
 * Setup container parameters by setting $_SERVER variables, first
 * looking at the env for the requested variable name, otherwise
 * setting it to the provided default value.
 *
 * @param string $varName      The env variable to check if it exists
 * @param mixed  $defaultValue The default value to use if it doesn't
 *
 * @return bool
 */
function testBootstrap__setupContainerParameter($varName, $defaultValue)
{
    if (false !== ($value = testBootstrap__getEnvVar($varName))) {
        return testBootstrap__setServerVar(
            $varName,
            $value
        );
    }

    return testBootstrap__setServerVar(
        $varName,
        $defaultValue
    );
}

/**
 * Setup the container parameters using a PHPUnit XML config file.
 *
 * @param string          $filePath  The file path to a valid PHPUnit XML config
 * @param \LogicException $exception Optional exception to throw on error, otherwise
 *                                   return boolean
 *
 * @return bool
 */
function testBootstrap__setupContainerParametersFromPHPUnitXML($filePath, \LogicException $exception = null)
{
    if (true !== file_exists($filePath)) {
        if ($exception !== null) {
            throw $exception;
        }

        return false;
    }

    $xml = simplexml_load_string(file_get_contents($filePath));
    $xmlElsSvr = (array) @$xml->xpath('php/server');

    foreach ($xmlElsSvr as $xmlEl) {
        $name = (string) @$xmlEl->attributes()->name[0];
        $value = (string) @$xmlEl->attributes()->value[0];

        if (substr($name, 0, 9) !== 'SYMFONY__') {
            continue;
        }

        testBootstrap__setupContainerParameter(
            str_replace('SYMFONY__', '', $name),
            $value
        );
    }
}

/**
 * @param string,... $parameters
 *
 * @return array
 */
function testBootstrap__getParametersFromPHPUnitXML(...$parameters)
{
    if (true !== file_exists(TEST_BS_FILE_PHPUNIT_LOCAL)) {
        testBootstrap__newLogicException(
            'Could not setup container parameter values/defaults via parsed PHPUnit file at %s.',
            TEST_BS_FILE_PHPUNIT_LOCAL
        );
    }

    $xml = simplexml_load_string(file_get_contents(TEST_BS_FILE_PHPUNIT_LOCAL));
    $xmlElsSvr = (array) @$xml->xpath('php/server');
    $return = [];

    foreach ($xmlElsSvr as $xmlEl) {
        $name = (string) @$xmlEl->attributes()->name[0];
        $value = (string) @$xmlEl->attributes()->value[0];

        if (false === ($index = array_search($name, $parameters))) {
            $return[] = null;
        } else {
            $return[] = $value;
        }
    }

    return $return;
}

/**
 * Set the provided server variable.
 *
 * @param string $varName The variable name to set
 * @param mixed  $value   The value to set it to
 *
 * @return bool
 */
function testBootstrap__setServerVar($varName, $value)
{
    global $_SERVER;

    $_SERVER[testBootstrap__translateServerVarName($varName)] = $value;

    return true;
}

/**
 * Attempt to get a variable from the enviornment.
 *
 * @param string $varName The name of the variable to search the enviornment for
 *
 * @return bool
 */
function testBootstrap__getEnvVar($varName)
{
    global $_ENV;

    if (false !== ($value = getenv($varName))) {
        return $value;
    }

    if (false !== (array_key_exists($varName, $_ENV))) {
        return $_ENV[$varName];
    }

    return false;
}

/**
 * Translate an env variable name to the special syntax required for Symfony
 * automatic container inclusion for $_SERVER variables.
 *
 * @param string $varName
 *
 * @return string
 */
function testBootstrap__translateServerVarName($varName)
{
    return (string) 'SYMFONY__'.$varName;
}

/* EOF */
