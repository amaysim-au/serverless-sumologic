ifdef DOTENV
	DOTENV_TARGET=dotenv
else
	DOTENV_TARGET=.env
endif

################
# Entry Points #
################

deploy: $(DOTENV_TARGET)
	docker-compose run --rm serverless make _deploy

remove: $(DOTENV_TARGET)
	docker-compose run --rm serverless make _remove

shell: $(DOTENV_TARGET)
	docker-compose run --rm serverless bash

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

_deploy:
	rm -fr .serverless
	sls deploy -v

_remove:
	sls remove -v
	rm -fr .serverless