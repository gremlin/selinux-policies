VERSION		?=	v0.0.4

all: release

clean: 
	rm -rf selinux-policies-$(VERSION)
	rm -f selinux-policies-$(VERSION).tar.gz

install-gremlin-container:
	semodule -i policies/gremlin-container.cil

uninstall-gremlin-container:
	semodule -r gremlin gremlin-openshift4

release:
	mkdir -p selinux-policies-$(VERSION)
	cp policies/gremlin-container.cil selinux-policies-$(VERSION)
	tar czf selinux-policies-$(VERSION).tar.gz selinux-policies-$(VERSION)
