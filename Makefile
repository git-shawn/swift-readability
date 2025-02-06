.PHONY: bootstrap
bootstrap:
	./bootstrap.sh

.PHONY: format
format:
	.nest/bin/swiftformat .

