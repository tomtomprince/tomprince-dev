.PHONY: dev preview deploy new

dev:
	scripts/dev

preview:
	scripts/preview

deploy:
	scripts/deploy

new:
	@printf "Title: " && read title && scripts/newpost "$$title"
