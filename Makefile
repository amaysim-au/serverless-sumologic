COMPOSE_RUN_SERVERLESS = docker-compose run --rm serverless
NODE = $(COMPOSE_RUN_SERVERLESS) npx babel-node

ifdef DOTENV
	DOTENV_TARGET=dotenv
else
	DOTENV_TARGET=.env
endif
ifdef AWS_ROLE
	ASSUME_REQUIRED?=assumeRole
endif

################
# Entry Points #
################

deps: $(DOTENV_TARGET)
	docker-compose run --rm serverless make _deps

deploy: $(DOTENV_TARGET) $(ASSUME_REQUIRED)
	docker-compose run --rm serverless make _deploy

remove: $(DOTENV_TARGET)
	docker-compose run --rm serverless make _remove

shell: $(DOTENV_TARGET)
	docker-compose run --rm serverless bash

assumeRole: .env
	docker run --rm -e "AWS_ACCOUNT_ID" -e "AWS_ROLE" amaysim/aws:1.1.3 assume-role.sh >> .env
.PHONY: assumeRole

##########
# Others #
##########
# Create .env based on .env.template if .env does not exist
.env:
	@echo "Create .env with .env.template"
	cp .env.template .env

# Create/Overwrite .env with $(DOTENV)
dotenv:
	@echo "Overwrite .env with $(DOTENV)"
	cp $(DOTENV) .env

# _deps depends on node_modules.zip and THEN node_modules
_deps: node_modules.zip node_modules

# if there is no node_modules.zip artefact then fetch from npm and make node_modules.zip artefact
node_modules.zip:
	yarn install --no-bin-links
	zip -rq node_modules.zip node_modules/

# if there is no node_modules directory then unzip from node_modules.zip artefact
node_modules:
	mkdir -p node_modules
	unzip -qo -d . node_modules.zip

_deploy:
	mkdir -p node_modules
	unzip -qo -d . node_modules.zip
	rm -fr .serverless
	sls deploy -v

_remove:
	sls remove -v
	rm -fr .serverless

cleanPolicy:
	$(NODE) scripts/clean_policy.js
