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

ciAudit: $(DOTENV_TARGET) auditFix deps
	git status | grep "nothing to commit" || (git commit -am 'auto-patched security vulnerabilities' && git push)

upgrade: $(DOTENV_TARGET)
	docker-compose run --rm serverless make _upgrade

audit: $(DOTENV_TARGET) deps
	docker-compose run --rm serverless make _audit

auditFix: $(DOTENV_TARGET)
	docker-compose run --rm serverless make _auditFix

_upgrade:
	yarn upgrade-interactive $(YARN_UPGRADE_VERSION)

_audit:
	yarn audit --level $(SECURITY_AUDIT_LEVEL)

_auditFix:
	yarn config set registry http://registry.npmjs.org
	yarn audit --level $(SECURITY_AUDIT_LEVEL) | grep "Low\|Moderate\|High\|Critical" && make _runAuditFix || echo "No high and critical vulnerabilities found."

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

_deps:
	yarn config set registry http://registry.npmjs.org
	yarn install --no-bin-links

_deploy:
	rm -fr .serverless
	sls deploy -v

_remove:
	sls remove -v
	rm -fr .serverless

cleanPolicy:
	$(NODE) scripts/clean_policy.js
