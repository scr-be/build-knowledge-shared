#!/bin/bash

cp $(dirname $0)/tpl-gitignore.txt $(pwd)/.gitignore
cp $(dirname $0)/tpl-contributing.md $(pwd)/CONTRIBUTING.md
cp $(dirname $0)/tpl-license.md $(pwd)/LICENSE.md
./$(dirname $0)/gen-struct.php tpl-readme-library.md
