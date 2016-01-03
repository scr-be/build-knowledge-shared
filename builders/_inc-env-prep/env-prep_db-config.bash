#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

RT_COMMANDS_ACT=(
  "mysql -uroot -p -e \"SET @@GLOBAL.default_storage_engine=InnoDB;\";"
  "mysql -uroot -p -e \"SET @@GLOBAL.innodb_strict_mode=1;\";"
  "mysql -uroot -p -e \"SET @@GLOBAL.innodb_file_per_table=1;\";"
  "mysql -uroot -p -e \"SET @@GLOBAL.innodb_file_format=Barracuda;\";"
  "mysql -uroot -p -e \"SET @@GLOBAL.innodb_large_prefix=1;\";"
  "mysql -uroot -p -e \"SET @@GLOBAL.character_set_server=utf8mb4;\";"
  "mysql -uroot -p -e \"SET @@GLOBAL.collation_server=utf8mb4_unicode_ci;\";"
)

# EOF #
