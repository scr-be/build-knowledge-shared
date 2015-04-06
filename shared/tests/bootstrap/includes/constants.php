<?php
/*
 * This file is part of the Scribe Mantle Bundle.
 *
 * (c) Scribe Inc. <source@scribe.software>
 *
 * For the full copyright and license information, please view the LICENSE.md
 * file that was distributed with this source code.
 */

error_reporting(E_ALL ^ E_STRICT ^ E_DEPRECATED);

/**
 * Umask of all files output using the console
 *
 * @var int
 */
define('TEST_BS_FILE_CONSOLE_APP_UMASK', 0002);

/**
 * Execution limit of console app (0 removes limit)
 *
 * @var int
 */
define('TEST_BS_FILE_CONSOLE_APP_EXEC_LIMIT', 0);

/**
 * Root directory of bundle
 *
 * @var string
 */
define('TEST_BS_ROOT', realpath(__DIR__.'/../../../../../'));

/**
 * Path to autoload include
 *
 * @var string
 */
define('TEST_BS_FILE_AUTOLOAD',   realpath(TEST_BS_ROOT.'/vendor/autoload.php'));

/**
 * Path to functions include
 *
 * @var string
 */
define('TEST_BS_FILE_FUNCTIONS',  realpath(__DIR__.'/functions.php'));

/**
 * Path to kernel include
 *
 * @var string
 */
define('TEST_BS_FILE_KERNEL',     realpath(__DIR__.'/kernel.php'));

/**
 * Path to loader include
 *
 * @var string
 */
define('TEST_BS_FILE_LOADER',     realpath(__DIR__.'/loader.php'));

/**
 * Path to kernel include
 *
 * @var string
 */
define('TEST_BS_FILE_CONSOLE_APP',     realpath(__DIR__.'/../console.php'));

/**
 * Path to our mock AppKernel
 *
 * @var string
 */
define('TEST_BS_FILE_APP_KERNEL', realpath(TEST_BS_ROOT.'/src/Tests/Helper/app/AppKernel.php'));

/**
 * Path to "local" version of PHPUnit file
 *
 * @var string
 */
define('TEST_BS_FILE_PHPUNIT_LOCAL', realpath(TEST_BS_ROOT.'/phpunit.local.xml'));

/**
 * Minimum PHPUnit version supported
 *
 * @var string
 */
define('TEST_BS_VER_MIN_PHPUNIT', '4.5');

/* EOF */
