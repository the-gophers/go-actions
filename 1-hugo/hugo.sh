[[ -z "${SITE_NAME:-}" ]] && SITE_NAME='1-hugo'
[[ -z "${SITE_BRANCH:-}" ]] && SITE_BRANCH='gh-pages-content'
[[ -z "${SITE_TITLE:-}" ]] && SITE_TITLE='Hello, Hugo!'
[[ -z "${SITE_BASEURL:-}" ]] && SITE_BASEURL='/'

function hugo-install-linux {
	echo "installing hugo"
	sudo mkdir -p hugo/
	VERSION="0.76.5"
	curl -L https://github.com/gohugoio/hugo/releases/download/v${VERSION}/hugo_${VERSION}_Linux-64bit.tar.gz | tar -zxf - --directory hugo/
	sudo mv hugo/hugo /usr/bin/
	sudo rm -rf hugo/
	hugo version
}

function hugo-new-site {
	hugo new site ${SITE_NAME} --force
	cd ${SITE_NAME}
	# git init
	git checkout -b ${SITE_BRANCH}
	git clone https://github.com/yihui/hugo-xmin.git themes/hugo-xmin/
	rm -rf themes/hugo-xmin/.git/
	git add themes/hugo-xmin/
	git commit -m "hugo: new site and add themes/hugo-xmin/"

CONFIG=$(cat <<EOF
title = "${SITE_TITLE}"
baseURL = "${SITE_BASEURL}"
theme = "hugo-xmin"
languageCode = "en-us"

[menu]
  [[menu.main]]
    identifier = "home"
    name = "${SITE_TITLE}"
    pre = "<i class='fa fa-heart'></i>"
    url = ""
    weight = 101

  [[menu.main]]
    identifier = "gophercon"
    name = "@GopherCon"
    pre = "<i class='fa fa-heart'></i>"
    url = "https://twitter.com/GopherCon/"
    weight = 102
EOF
)
	printf "%s" "$CONFIG" > config.toml

	hugo new posts/my-first-post.md
	git add .
	git commit -m "hugo: add config.toml and first post"

	git push -u origin ${SITE_BRANCH}
	cd ../
}

function hugo-github-init {
	cd ${SITE_NAME}/
	git checkout --orphan gh-pages
	git reset --hard
	git commit --allow-empty -m "Initializing gh-pages branch"
	git push origin gh-pages
	git checkout ${SITE_BRANCH}
	git worktree add -B gh-pages public origin/gh-pages
	cd ../
}

function hugo-github-deploy {
	cd ${SITE_NAME}/
	if ! test -d public/
	then
		echo "public/ does not exist. running git worktree add..."
		git fetch origin
		git worktree add -B gh-pages public origin/gh-pages
	fi
	
	rm -rf public/*
	hugo

	cd public
	git add --all
	git commit -m "publish"
	cd ../
	git push origin gh-pages
	cd ../
}

function hugo-reset {
	git worktree remove hello-gophercon/public
	rm -rf hello-gophercon
}

