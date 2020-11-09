# Tell your Story with Hugo, GitHub Pages and GitHub Actions Workflows

## What is Hugo?

[Hugo](https://gohugo.io/) is one of the most popular static site generators. It is open source, written in Go, and blazingly fast.

Hugo enables us to write our content in [markdown](https://daringfireball.net/projects/markdown/syntax) in the editor of our choice, create themes using Go's [html/template](https://golang.org/pkg/html/template/) and [text/template](https://golang.org/pkg/text/template/).

Hugo is often used for blogs, but also works extremely well for everything from a simple landing page, resume, or product site, to complex documentation learning resources or presentations, and has well maintained themes for all of these and more.

## What is GitHub Pages?

[GitHub Pages](https://pages.github.com/) provides free static site hosting for you, your organization, and your projects, hosted directly from your GitHub repository. Just edit, push, and your changes are live.

By default you will receive a URL in the format `username.github.io` or `organization.github.io`, where you can host a site directly at the root, or host your project at username.github.io/repository. We will be using the project option by default as we experiment. GitHub Pages supports the [Jekyll](https://jekyllrb.com/) static site generator natively, but since it deploys static HTML pages and assets, we can build [Hugo](https://gohugo.io/) static sites with [GitHub Actions](https://github.com/features/actions).

It is worth mentioning that [Azure Static Web Apps (Preview)](https://docs.microsoft.com/en-ca/azure/static-web-apps/overview) is another feature-rich option that uses GitHub Actions to build and deploy your static web app, and has [native support for Hugo](https://docs.microsoft.com/en-us/azure/static-web-apps/publish-hugo), amongst other popular static site and front-end frameworks, and has support for APIs, routing, authentication, authorization, pre-production environments for Pull Requests, and more. However, our focus today is to explore GitHub Actions via Hugo, as a Go CLI tool, and how we can automate and create a GitHub Actions workflow from scratch, without any local or external dependencies, or needing to leave our GitHub repository.

## Introduction

If you are new to Hugo, you may want to follow these steps locally. You can follow Hugo's [Quick Start](https://gohugo.io/getting-started/quick-start/) to install Hugo, choose a [Hugo Theme](https://themes.gohugo.io/), and test locally. This includes the [hugo server](https://gohugo.io/getting-started/quick-start/) command which lets you preview locally, including [draft, future, or expired](https://gohugo.io/getting-started/usage/#draft-future-and-expired-content) content, and a [LiveReload](https://gohugo.io/getting-started/usage/#livereload) feature that enable you to see your edits in realtime.

For the purposes of this lab, and for use inside GitHub Actions, we have tweaked and wrapped the Quick Start and [Host on GitHub](https://gohugo.io/hosting-and-deployment/hosting-on-github/) steps into bash functions in [hugo.sh](1-hugo/hugo.sh). We will step through [hugo.sh](1-hugo/hugo.sh), but you can use it locally, or go through the same steps manually, if you prefer.

We also include our first (optional) GitHub Action (`1-hugo-setup`) that can bootstrap our first site, the `gh-pages` and `gh-pages-content` branches, along with a clean easy to modify theme, [hugo xmin](https://themes.gohugo.io/hugo-xmin/), without any local tools or need to leave GitHub.

## Let's setup our first Hugo site with Actions

1. Open the [the-gophers/go-actions](https://github.com/the-gophers/go-actions) and click the "Use this template" button.
    > [Template repositories](https://github.blog/2019-06-06-generate-new-repositories-with-repository-templates/) are a useful way to make any project project or sample simple to share and be used as a starting point by others. GitHub Actions workflows are included whenever a repo is used as a template repo, or forked.
1. Select your own account and create a new repository. Leaving the name `go-actions` is a good option.
1. Check the `Include all branches` box before clicking the `Create repository from template` button.
1. Click the `Actions` tab on your newly created repo.
1. Look for the `1-hugo-setup` action on the left hand side. You will see it says "This workflow has a workflow_dispatch event trigger." and you can click `Run workflow`, leave the `Branch: main` by default, and click `Run workflow`. Here you can also supply additional [inputs](https://docs.github.com/en/free-pro-team@latest/actions/creating-actions/metadata-syntax-for-github-actions#inputs) to a `workflow_dispatch` action. We've left an example input called `debug` with a default value of `true`.
    > Note: the `Branch` option will decide both which version of an Actions workflow, and the branch that is checked out when the action runs. In order for a workflow to appear here it must also be present in the default branch of the repo.
1. Click on the `Actions` tab again, and you will see the action is now running. Click on the action, and then click the job name, `deploy`, where you will see live logs of the build.
1. In less than a minute, the `1-hugo-setup` workflow will use the `hugo.sh` script to bootstrap a static site in a new `gh-pages-content` branch inside the `current` repo, including new site, the [hugo xmin](https://themes.gohugo.io/hugo-xmin/) theme which we have chosen for you, configuration via [config.toml](https://gohugo.io/getting-started/configuration/#example-configuration), and a new post under `content/posts` with `draft: true` set in its [front matter](https://gohugo.io/content-management/front-matter/#front-matter-variables).
1. Your `1-hugo/` folder in the `gh-pages-content` branch of your repository should now look like this:
	```
	.
	|-- README.md
	|-- archetypes
	|   `-- default.md
	|-- config.toml
	|-- content
	|   `-- posts
	|       `-- my-first-post.md
	|-- hugo.sh
	|-- themes
	   `-- hugo-xmin
	```

So how did all this happen? In this repository we have 2 workflows and 1 shell script for this lab:

```shell script
.
├── .github
│   └── workflows
│       ├── 1-hugo-setup.yml
│       └── 1-hugo-deploy.yml
└── 1-hugo
    ├── README.md
    └── hugo.sh
```

#### [1-hugo.sh](./1-hugo.sh)

Let's begin with `1-hugo.sh`, which contains a handful of bash functions:

- `hugo-install-linux` installs Hugo for linux by downloading and extracting the Go binary directly from [gohugoio/hugo's Releases](https://github.com/gohugoio/hugo/releases) page.
- `hugo-new-site` runs `hugo new site` and creates a new site, which is checked into the git repository on the `gh-pages-content` branch. We are creating this by convention so that your site content is separate from the rest of the sample repo. Note, that because this folder already existed, and had `hugo.sh` in it, we had to use the `--force` flag for `hugo new site`. You can delete the `gh-pages-content` branch at any time and re-run the `1-hugo-setup` action to experiment further.
- `hugo-github-init` creates the `gh-pages` branch required to deploy to GitHub actions. Your remote must be called `origin`, as this is hard-coded in `hugo.sh`.
- `hugo-github-deploy` builds your site, and uses the [git worktree](https://gohugo.io/hosting-and-deployment/hosting-on-github/#build-and-deployment) command to ensure the `public/` folder our content is generated to is part of the `gh-pages` branch. We are taking this extra step to keep your site and its markdown-formatted content separate from the HTML files and other static assets that will be generated on every change.
- `hugo-reset` is not used during setup or deployment, but will remove the [git-worktree](https://git-scm.com/docs/git-worktree), that points to the `gh-pages` branch, if needed.

Now let's publish your first piece of content.

8. Find the `gh-pages-content` branch and navigate to the same `1-hugo/` folder where your site is now located. Find `content/posts/` and open `my-first-post.md`. Remove the line that says `draft: true` and commit that change.
9. Your second GitHub Actions workflow, `1-hugo-deploy`, will kick off immediately. Click the `Actions` tab to have a look at the output.
10. Click on the `Settings` tab of your GitHub repository, and scroll down to `GitHub Pages`. You should see a message that says: "Your site is published at <https://the-gophers.github.io/go-actions/>". Here you will see other options such as custom domains and to use a branch other than `gh-pages`. GitHub Pages are always public, but they can be generated from a repository that remains private. If for any reason your site hasn't already been generated, select the `gh-pages` branch here, or make any commit to the pre-existing `gh-pages` branch (e.g. add a README.md).

Congratulations! You've used your first [GitHub Actions workflow](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-syntax-for-github-actions) stored in a YAML file under [.github/workflows/1-hugo-setup.yml](.github/workflows/1-hugo-setup.yml) [manually triggered by a `workflow_dispatch` event](https://docs.github.com/en/free-pro-team@latest/actions/reference/events-that-trigger-workflows#manual-events). Your second [GitHub Actions workflow](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-syntax-for-github-actions) stored in a YAML file under [.github/workflows/1-hugo-deploy.yml](.github/workflows/1-hugo-deploy.yml), was triggered by the [push event](https://docs.github.com/en/free-pro-team@latest/actions/reference/events-that-trigger-workflows#example-using-multiple-events-with-activity-types-or-configuration) which is one of 27 webhook events, the cron-like [schedule](https://docs.github.com/en/free-pro-team@latest/actions/reference/events-that-trigger-workflows#scheduled-events) event, and 2 manual ([workflow_dispatch](https://docs.github.com/en/free-pro-team@latest/actions/reference/events-that-trigger-workflows#workflow_dispatch), [repository_dispatch](https://docs.github.com/en/free-pro-team@latest/actions/reference/events-that-trigger-workflows#repository_dispatch)) events that can trigger Actions workflows.

## The anatomy of an Actions workflow

Both `1-hugo-setup` and `1-hugo-deploy` use a single Action called [Checkout V2](https://github.com/marketplace/actions/checkout), which lives inside the public [github.com/actions/checkout](https://github.com/actions/checkout#checkout-v2) repository. The `actions/checkout@v2` Action is included by default with most workflows (if you click `Actions > New workflow > Simple workflow > Setup this workflow`, for example), and checks-out your repository under `$GITHUB_WORKSPACE`, one of a number of [default environment variables](https://docs.github.com/en/free-pro-team@latest/actions/reference/environment-variables#default-environment-variables) that GitHub Actions sets.

The V2 of this action enables your scripts to run authenticated git commands by persisting an automatic [GITHUB_TOKEN](https://docs.github.com/en/free-pro-team@latest/actions/reference/authentication-in-a-workflow#about-the-github_token-secret) GitHub Actions [Secret](https://docs.github.com/en/free-pro-team@latest/actions/reference/encrypted-secrets) that GitHub creates as as part of every workflow to your local git config.

GitHub Actions workflows are defined in YAML. Let's look at the syntax for the simplest workflow we have created.

> Note: Editing YAML by hand can be a hassle for many developers, but the GitHub web interface has its own [YAML workflow editor](https://github.blog/2019-10-01-new-workflow-editor-for-github-actions/) with auto-completion, linting and even help with cron expressions.

Both workflows begin with the [name](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-syntax-for-github-actions#name), and the [on](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-syntax-for-github-actions#on) section where we define the [events](https://docs.github.com/en/free-pro-team@latest/actions/reference/events-that-trigger-workflows) that trigger them. In `1-hugo-setup.yml`, [workflow_dispatch](https://docs.github.com/en/free-pro-team@latest/actions/reference/events-that-trigger-workflows#workflow_dispatch) takes [inputs](https://docs.github.com/en/free-pro-team@latest/actions/creating-actions/metadata-syntax-for-github-actions#inputs) that are passed via the `github.event.inputs` payload on the [github](https://docs.github.com/en/free-pro-team@latest/actions/reference/context-and-expression-syntax-for-github-actions#github-context) context that contains other useful values such as `github.sha` and `github.event.respository.name` which we use to set a `SITE_BASEURL` [environment variable](https://docs.github.com/en/free-pro-team@latest/actions/reference/environment-variables#about-environment-variables) under `env` and later use to set [baseURL in our config.toml](https://gohugo.io/getting-started/configuration/#all-configuration-settings) using [context expression syntax](https://docs.github.com/en/free-pro-team@latest/actions/reference/context-and-expression-syntax-for-github-actions#contexts).

We define a [job](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-syntax-for-github-actions#jobs) named `deploy` with a [step](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-syntax-for-github-actions#jobsjob_idsteps) named `hugo.sh` that [runs-on](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-syntax-for-github-actions#jobsjob_idruns-on) `ubuntu-latest`. The linux `ubuntu-latest` runner  defaults to `ubuntu-18.04`, but `ubuntu-16.04` and `ubuntu-20.04` are also options alongside Windows Server 2019 (`windows-latest`/`windows-2019`), macOS Big Sur (`macos-11.0`), macOS Catalina (`macos-latest`/`macos-10.15`), or free [self-hosted](https://docs.github.com/en/free-pro-team@latest/actions/hosting-your-own-runners/about-self-hosted-runners) (`self-hosted`) runners.

Finally, we use our step's [run](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-syntax-for-github-actions#jobsjob_idstepsrun) command (which defaults to bash) to run a multi-line script. In order to commit to our repo, we need to set our `user.name` and `user.email` via `git config`, and we then `source` our `hugo.sh`, before running our bash functions. `source` lets us use the environment variables we've set without exporting them.

#### [.workflows/github/1-hugo-setup.sh](./.workflows/github/1-hugo-setup.sh)

```yaml
name: 1-hugo-setup

on:
  workflow_dispatch:
    inputs:
      site_title:
        description: 'Site Title'
        default: 'Hello, GopherCon!'
        required: true
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: hugo.sh
      env:
        GITHUB_SHA: ${{ github.sha }}
        SITE_TITLE: ${{ github.event.inputs.site_title }}
        SITE_BASEURL: "/${{ github.event.repository.name }}/"
        SITE_NAME: 1-hugo
      run: |
        git config --global user.name github-actions
        git config --global user.email github-actions@github.com
        cd /home/
        source $GITHUB_WORKSPACE/1-hugo/hugo.sh
        hugo-install-linux
        cd $GITHUB_WORKSPACE/
        hugo-new-site
        hugo-github-init
        hugo-github-deploy
```

Our `1-hugo-deploy` action is very similar to the above, with the exception of the [push](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-syntax-for-github-actions#onpushpull_requestbranchestags) trigger which we use to filter on a branch:

#### [.workflows/github/1-hugo-deploy.sh](./.workflows/github/1-hugo-deploy.sh)

```yaml
on:
  push:
    branches:
    - gh-pages-content
```


## Summary

In this brief workflow we've explored GitHub Actions workflows through a quite straightforward workflow that installs and runs a Go CLI tool and using bash scripts as part of our workflow.

Many of the steps we have may have their own, dedicated, Actions in the GitHub Marketplace.

For example, there are official actions for [Go](https://github.com/marketplace/actions/setup-go-environment) which provide more advanced functionality than running `go build` using the version that is pre-installed on every runner. The community has created many [Hugo](https://github.com/marketplace?type=actions&query=hugo) actions you may find useful.

It can often be helpful to strike a balance between your existing tools and workflows, particularly those you use locally, and what gets run in the cloud. This is especially true when debugging. The debug loop is much tighter when you can hack on a bash script locally, and then push it to GitHub Actions knowing it will run the same as it does locally.

Finally, Go CLI tools are ideal for GitHub Actions workflows. Go binaries are very quick to install (Hugo takes single-digit seconds), and while Actions workflows also support both `docker` and `docker-compose` that can be great for complex build environments, Go binaries are often a solid alternative to packaging an environment as a container.

We will continue to explore similar workflows in our next labs covering Go in Serverless Functions and Containers in the Cloud.

## Ideas

- Hack on your site, configure, and modify your existing theme, or [choose a new one](https://themes.gohugo.io).
- Is it a landing page? A resume? A blog? Documentation for your GitHub project?
- Could you integrate [wjdp/htmltest](https://github.com/wjdp/htmltest) into your workflow to check for broken links? You could do this via shell scripting, or perhaps an existing Action in the Marketplace.
- Consider how you might integrate more dynamic content into your site, or implement more advanced functionality such as publishing posts on a schedule.
