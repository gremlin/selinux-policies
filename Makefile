all: gremlin.cil

clean: 
	rm -fr udica/
	rm -f gremlin.cil

gremlin.cil: udica/udica/templates
	cat udica/udica/templates/base_container.cil udica/udica/templates/net_container.cil policies/gremlin_container.cil > $@

udica/udica/templates:
	git clone https://github.com/containers/udica

install:
	semodule -i gremlin.cil

uninstall:
	semodule -r gremlin