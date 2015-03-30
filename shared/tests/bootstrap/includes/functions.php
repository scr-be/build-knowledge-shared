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
 * Create new LogicException instance
 *
 * @param string   $message       The error message (passed to sprintf)
 * @param ...mixed $substitutions The message substitutions (passed to sprintf)
 *
 * @return \LogicException
 */
function testBootstrap__newLogicException($message, ...$substitutions)
{
    return (new \LogicException(
        call_user_func_array('sprintf', array_merge((array)$message, (array)$substitutions))
    ));
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
 * Attempt to include a file if it exists
 *
 * @param string               $filePath  File path to include
 * @param \LogicException|null $exception Optional exception to throw on error, otherwise
 *                                        return false if null
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

    return include_once($filePath);
}

/**
 * Attempt to include a file if it exists
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
 * Remove directory if it exists
 *
 * @param string $path Path to remove
 *
 * @return bool
 */
function testBootstrap__removeDirectory($path)
{
    if (false === is_dir($path)) {
        return false;
    }

    foreach ((array)glob($path.'/*') as $file) {
        is_dir($file) ? removeDirectory($file) : unlink($file);
    }

    return rmdir($path);
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
 * Setup the container parameters using a PHPUnit XML config file
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


}

/**
 * Set the provided server variable
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
 * Attempt to get a variable from the enviornment
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
