# Copyright 1999-2013 FOSS-Group, Germany
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

MY_PN="configuration-overlay"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="FOSS-Cloud configuration files"
HOMEPAGE="http://www.foss-cloud.org/"
SRC_URI="http://github.com/FOSS-Cloud/${MY_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="EUPL"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND=""
RDEPEND=">=sys-apps/sst-syslog-ng-configuration-1.0.0
	app-admin/logrotate
	app-admin/webapp-config
	app-emulation/libvirt
	app-portage/layman
	dev-lang/php
	net-dns/pdns-recursor
	net-misc/dhcp
	net-misc/ntp
	net-misc/openssh
	net-nds/openldap
	sys-apps/baselayout
	sys-apps/openrc
	sys-apps/portage
	sys-apps/sysvinit
	sys-libs/glibc
	www-servers/apache"

S="${WORKDIR}/${MY_P}"

src_install() {
	doconfd conf.d/{hwclock,keymaps,net,apache2,libvirtd,ucarp.int,ucarp.pub}
	doinitd init.d/{dhcpd,slapd}
	doenvd env.d/02locale env.d/99editor

	keepdir /etc/config-archive

	# no recursive install on purpose
	insinto /etc
	doins *

	# do not install /etc/libvirt/qemu/networks/default.xml on purpose since we
	# don't want the default libvirt network and we keep it for blanking it out
	insinto /etc/libvirt
	doins libvirt/*
	insinto /etc/libvirt/storage
	doins libvirt/storage/*.xml

	for d in layman portage profile.d ssh dhcp kernels apache2 openldap foss-cloud php powerdns vhosts sysctl.d logrotate.d ; do
		insinto "/etc/${d}"
		doins -r "${d}"/*
	done

	# Replace our default config for building packages with the option to use
	# binary packages. This has no influence in the build environment since this
	# file gets filtered out by our installation mask anyway.
	sed -i \
		-e 's|buildpkg|getbinpkg|' \
		"${D}/etc/portage/make.conf" || die "sed failed"

	fperms 0640 /etc/openldap/slapd.conf
	fowners root:ldap /etc/openldap/slapd.conf

	# SSH ignores the file if worl-readable
	fperms 0600 /etc/ssh/sshd_config

	keepdir /var/log/archive
	keepdir /var/virtualization
}
