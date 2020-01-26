.PHONY: install test

GEM=composer-summary-$(shell bin/composer-summary -v).gem

install: $(GEM)
	gem install $(GEM)

$(GEM): composer-summary.gemspec
	gem build composer-summary.gemspec

test:
	ruby test/ts_all.rb --use-color
