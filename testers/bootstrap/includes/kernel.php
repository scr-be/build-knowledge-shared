<?php
/*
 * This file is part of the Scribe Mantle Bundle.
 *
 * (c) Scribe Inc. <source@scribe.software>
 *
 * For the full copyright and license information, please view the LICENSE.md
 * file that was distributed with this source code.
 */

require_once(realpath(__DIR__.'/constants.php'));
require_once(TEST_BS_FILE_FUNCTIONS);

testBootstrap__removeDirectory(realpath(__DIR__.'/../../../../../../src/Tests/app/cache/'));
testBootstrap__removeDirectory(__DIR__.'/app/cache/');

$loader = testBootstrap__requireFileOnce(
    TEST_BS_FILE_AUTOLOAD,
    testBootstrap__newLogicException(
        'Could not find autoload file at %s.',
        TEST_BS_FILE_AUTOLOAD
    )
);

testBootstrap__requireFileOnce(
    TEST_BS_FILE_APP_KERNEL,
    testBootstrap__newLogicException(
        'Could not find testing AppKernel at %s.',
        TEST_BS_FILE_APP_KERNEL
    )
);

return $loader;

/* EOF */
