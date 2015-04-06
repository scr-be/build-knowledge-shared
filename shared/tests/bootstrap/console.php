<?php
/*
 * This file is part of the Scribe Mantle Bundle.
 *
 * (c) Scribe Inc. <source@scribe.software>
 *
 * For the full copyright and license information, please view the LICENSE.md
 * file that was distributed with this source code.
 */

require_once(realpath(__DIR__.'/includes/constants.php'));
require_once(TEST_BS_FILE_FUNCTIONS);

testBootstrap__setupContainerParametersFromPHPUnitXML(
    TEST_BS_FILE_PHPUNIT_LOCAL,
    testBootstrap__newLogicException(
        'Could not setup container parameter values/defaults via parsed PHPUnit file at %s.',
        TEST_BS_FILE_PHPUNIT_LOCAL
    )
);

$loader = require_once(TEST_BS_FILE_KERNEL);

use Symfony\Bundle\FrameworkBundle\Console\Application;
use Symfony\Component\Console\Input\ArgvInput;
use Symfony\Component\Debug\Debug;

$input = new ArgvInput();
$env = $input->getParameterOption(array('--env', '-e'), getenv('SYMFONY_ENV') ?: 'test');
$debug = getenv('SYMFONY_DEBUG') !== '0' && !$input->hasParameterOption(array('--no-debug', '')) && $env !== 'prod';

if ($debug) {
    Debug::enable();
}

$kernel = new \AppKernel($env, $debug);
return (new Application($kernel))->run($input);

/* EOF */
