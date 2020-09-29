COMPOSE_RUN_SERVERLESS = docker-compose run --rm serverless
NODE = $(COMPOSE_RUN_SERVERLESS) npx babel-node
YARN_UPGRADE_VERSION=--latest
SECURITY_AUDIT_LEVEL=low

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

build: $(DOTENV_TARGET)
	docker-compose run --rm serverless make _build

deploy: $(DOTENV_TARGET) $(ASSUME_REQUIRED)
	docker-compose run --rm serverless make _deploy

remove: $(DOTENV_TARGET)
	docker-compose run --rm serverless make _remove

shell: $(DOTENV_TARGET)
	docker-compose run --rm serverless bash

assumeRole: .env
	docker run --rm -e "AWS_ACCOUNT_ID" -e "AWS_ROLE" amaysim/aws:1.1.3 assume-role.sh >> .env
.PHONY: assumeRole

#####################
# Security Patching #
#####################

ciAudit: $(ENVFILE) auditFix deps test
	git status | grep "nothing to commit" || (git commit -am 'auto-patched security vulnerabilities' && git push)

upgrade: $(ENVFILE) #deps
	docker-compose run --rm serverless make _upgrade

audit: $(ENVFILE) deps
	docker-compose run --rm serverless make _audit

auditFix: $(ENVFILE)
	docker-compose run --rm serverless make _auditFix

_upgrade:
	yarn upgrade-interactive $(YARN_UPGRADE_VERSION)

_audit:
	yarn audit --level $(SECURITY_AUDIT_LEVEL)

_auditFix: _registry
	yarn audit --level $(SECURITY_AUDIT_LEVEL) | grep "Low\|Moderate\|High\|Critical" && make _runAuditFix|| echo "No high and critical vulnerabilities found."

_runAuditFix:
	npm i --package-lock-only
	npm audit fix
	rm yarn.lock
	yarn import
	yarn audit --level $(SECURITY_AUDIT_LEVEL)
	rm -rf package-lock.json node_modules

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

_registry:
	echo "//registry.npmjs.org/:_authToken=$(NPM_TOKEN)" >> .npmrc
	yarn config set registry http://registry.npmjs.org

_deps: _registry
	yarn install --no-bin-links

# if there is no node_modules.zip artefact then fetch from npm and make node_modules.zip artefact
node_modules.zip: _registry _deps
	zip -rq node_modules.zip node_modules/

# if there is no node_modules directory then unzip from node_modules.zip artefact
node_modules:
	mkdir -p node_modules
	unzip -qo -d . node_modules.zip

_build: node_modules.zip node_modules

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
