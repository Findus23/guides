server:
	./hugo server -D

build:
	rm -fr public.bak/
	mv public public.bak
	./hugo
	diff -r public.bak public || true

publish:
	rsync -aP public/ lw1.at:/var/www/guides/ --delete
