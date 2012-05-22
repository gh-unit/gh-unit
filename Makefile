
NAME=GHUnit
COMPANY_ID=me.rel
GITHUB_DOC_URL=http://gabriel.github.com/gh-unit
VERSION=$(shell cat XcodeConfig/Shared.xcconfig | grep "GHUNIT_VERSION =" | cut -d '=' -f 2 | tr -d " ")

docs:
	rm -rf Documentation/output
	appledoc -o Documentation/output -p $(NAME) -v $(VERSION) -c "$(NAME)" --company-id "$(COMPANY_ID)" --warn-undocumented-object --warn-undocumented-member --warn-empty-description --warn-unknown-directive --warn-invalid-crossref --warn-missing-arg --no-repeat-first-par --keep-intermediate-files --docset-feed-url $(GITHUB_DOC_URL)/publish/%DOCSETATOMFILENAME --docset-package-url $(GITHUB_DOC_URL)/publish/%DOCSETPACKAGEFILENAME --publish-docset --index-desc Documentation/index_desc.txt --include Documentation/appledoc_include/ --include Documentation/index-template.markdown --verbose=3 --create-html --create-docset --publish-docset --exit-threshold 2 Classes/ Classes-iOS/ Classes-MacOSX/

gh-pages: docs
	rm -rf ../doctmp
	mkdir -p ../doctmp
	cp -R Documentation/output/html/* ../doctmp
	cp -R Documentation/output/publish ../doctmp/publish
	rm -rf Documentation/output/*
	git checkout gh-pages
	git symbolic-ref HEAD refs/heads/gh-pages
	rm .git/index
	git clean -fdx
	cp -R ../doctmp/* .
	git add .
	git commit -a -m 'Updating docs' && git push origin gh-pages
	git checkout master
