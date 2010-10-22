
docs:
	/Applications/Doxygen.app/Contents/Resources/doxygen
	mkdir -p Documentation
	cd Documentation/html && make install
	cd ~/Library/Developer/Shared/Documentation/DocSets/ && tar zcvpf GHUnit.docset.tgz GHUnit.docset
	mv ~/Library/Developer/Shared/Documentation/DocSets/GHUnit.docset.tgz Documentation

gh-pages: docs
	rm -rf build
	git checkout gh-pages
	cp -R Documentation/html/* .
	rm -rf Documentation
	git add .
	git commit -a -m 'Updating docs' && git push origin gh-pages
	git checkout master
