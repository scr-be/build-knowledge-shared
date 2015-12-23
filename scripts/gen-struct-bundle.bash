#!/bin/bash

cp $(dirname $0)/tpl-gitignore.txt $(pwd)/.gitignore
./$(dirname $0)/gen-struct-bundle.php
