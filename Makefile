server:
	hugo server -D

build:
	rm -r public/
	hugo

publish:
	rsync -aP public/ lw1.at:/var/www/guides/ --delete-after
