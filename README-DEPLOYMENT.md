# Prediction Book

There are two prediction-book repositories to

* `predictionbook` : Allow engaged prediction-book users to contribute changes.
* `predictionbook-deploy` : Allow us to keep prediction-book deployment / setup information safe.

## Public repository

All functional changes should (must) be done on this repository. Contributors make pull requests to this repository.

	git@github.com:tricycle/predictionbook.git

## Deploy repository

All changes made to the public repository need to be pulled into this repository.

This repository contains additional deployment and setup information **(that cannot go into the secrets repo)**, all other sources should be in-sync.

**Changes to this repository must not be pushed to the public repository.**

	git@github.com:tricycle/predictionbook-deploy.git`

### Configure deploy repository with remote public repository

* Within the local clone of the deploy repository, add the public repository as a new remote

  `git remote add public git@github.com:tricycle/predictionbook.git`

* In order to NOT push changes from the deploy to the public repository, cripple the push url

  `git remote set-url --push public no-pushing`

### Pull changes from the public repository

* Fetch changes from public repository
  
  `git fetch public`

* Merge changes from public repository
  
  `git merge public/master --no-ff`

* Push changes to deploy repository

  `git push origin master`

### Deploy to production (from stable)

	git checkout stable

	git merge master --no-ff

    git push origin stable

	cap production deploy
