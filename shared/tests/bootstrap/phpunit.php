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

$loader = require_once(TEST_BS_FILE_LOADER);

if (!class_exists('\PHPUnit_Framework_TestCase') ||
    version_compare(\PHPUnit_Runner_Version::id(), TEST_BS_VER_MIN_PHPUNIT) < 0) {
    testBootstrap__fatalError(
        'PHPUnit framework (version >=%s) is required for testing.',
        TEST_BS_VER_MIN_PHPUNIT
    );
}

require_once(TEST_BS_FILE_KERNEL);

return $loader;

/* EOF */
