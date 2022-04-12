server:
	hugo server -D

build:
	rm -fr public/
	hugo

publish:
	rsync -aP public/ lw1.at:/var/www/guides/ --delete
