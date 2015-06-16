#grep -r '$this->utils' {src,lib}/**/**/Controller/*.php | sed -r 's/.*(this->utils->[A-Za-z]+).*/\1/g' | sort | uniq
grep -r '$this->utils' {src,lib}/**/**/Controller/*.php | sed -r 's/.*(this->utils->[A-Za-z]+).*/\1/g'
