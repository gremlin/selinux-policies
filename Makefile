VERSION		?=	v0.0.1

all: gremlin-openshift3.cil

clean: 
	rm -fr udica/
	rm -f gremlin-openshift3.cil

gremlin-openshift3.cil: udica/udica/templates
	cat udica/udica/templates/base_container.cil udica/udica/templates/net_container.cil policies/gremlin-openshift3.cil > $@

udica/udica/templates:
	git clone https://github.com/containers/udica

install-openshift3:
	semodule -i gremlin-openshift3.cil

uninstall:
	semodule -r gremlin

release:
	mkdir -p selinux-policies-$(VERSION)
	cp gremlin-openshift3.cil selinux-policies-$(VERSION)
	tar czf selinux-policies-$(VERSION).tar.gz selinux-policies-$(VERSION)
