.PHONY: build
build:
	packer init packer/minecraft-server-ubuntu.pkr.hcl
	cd packer && packer build -var-file=variables.pkrvars.hcl minecraft-server-ubuntu.pkr.hcl