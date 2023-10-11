VERSION		?=	v0.0.2

all: gremlin-openshift4.cil

clean: 
	rm -fr udica/
	rm -f gremlin-openshift3.cil

gremlin-openshift3.cil: udica/udica/templates
	cat udica/udica/templates/base_container.cil udica/udica/templates/net_container.cil policies/gremlin-openshift3.cil > $@

gremlin-openshift4.cil: udica/udica/templates
	cat udica/udica/templates/base_container.cil udica/udica/templates/net_container.cil policies/gremlin-openshift4.cil > $@

bottlerocket.cil: udica/udica/templates
	cat udica/udica/templates/base_container.cil udica/udica/templates/net_container.cil bottlerocket.cil > $@

udica/udica/templates:
	git clone https://github.com/containers/udica

install-openshift3:
	semodule -i gremlin-openshift3.cil

install-openshift4:
	semodule -i gremlin-openshift4.cil

uninstall-openshift3:
	semodule -r gremlin gremlin-openshift3

uninstall-openshift4:
	semodule -r gremlin gremlin-openshift4

release: gremlin-openshift3.cil gremlin-openshift4.cil
	mkdir -p selinux-policies-$(VERSION)
	cp gremlin-openshift3.cil selinux-policies-$(VERSION)
	cp gremlin-openshift4.cil selinux-policies-$(VERSION)
	tar czf selinux-policies-$(VERSION).tar.gz selinux-policies-$(VERSION)
