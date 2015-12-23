#!/bin/bash

echo "Creating basic repo skeleton [library tpl]..."

echo -n "!!! You must execute this from the repo root! Continue? [^C to cancel] "
read TMP

if [ -f .scrutinizer.yml ]
then
	echo "Removing: .scrutinizer.yml"
	rm .scrutinizer.yml
fi

echo "Overridding: .gitignore"
cp $(dirname $0)/tpl-gitignore.txt $(pwd)/.gitignore

echo "Overridding: .coveralls.yml"
cp $(dirname $0)/tpl-coveralls.txt $(pwd)/.coveralls.yml

echo "Overridding: CONTRIBUTING.md"
cp $(dirname $0)/tpl-contributing.md $(pwd)/CONTRIBUTING.md

echo "Overridding: LICENSE.md"
cp $(dirname $0)/tpl-license.md $(pwd)/LICENSE.md

echo "Generating: README.md"
echo "---"

./$(dirname $0)/gen-struct.php tpl-readme-library.md

echo "---"

echo "Complete!"
