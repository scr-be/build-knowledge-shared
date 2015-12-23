#!/bin/bash

echo -e "###\n### Creating basic repo skeleton [BUNDLE]\n###\n"

echo -n "!!! You must execute this from the repo root! Continue? [^C to cancel] "
read TMP
echo ""

if [ -f .scrutinizer.yml ]
then
	echo "Removing: .scrutinizer.yml"
	rm .scrutinizer.yml
fi

echo "Overridding:"
echo "  - '.gitignore'"
cp $(dirname $0)/tpl-gitignore.txt $(pwd)/.gitignore

echo "  - '.coveralls.yml'"
cp $(dirname $0)/tpl-coveralls.txt $(pwd)/.coveralls.yml

echo "  - 'CONTRIBUTING.md'"
cp $(dirname $0)/tpl-contributing.md $(pwd)/CONTRIBUTING.md

echo "  - 'LICENSE.md'"
cp $(dirname $0)/tpl-license.md $(pwd)/LICENSE.md

echo -e "\n--- EXEC gen-struct.php --- START"

./$(dirname $0)/gen-struct.php tpl-readme-bundle.md

echo -e "\n--- EXEC gen-struct.php --- DONE\n"

echo -e "Complete!\n"
