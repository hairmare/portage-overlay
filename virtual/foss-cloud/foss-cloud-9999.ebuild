# Copyright 1999-2012 FOSS-Group, Germany
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

DESCRIPTION="virtual package to pull in FOSS-Cloud packages"
HOMEPAGE="http://www.foss-cloud.org/"

LICENSE="EUPL"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+cifs +ipmi +zabbix"

DEPEND=""
RDEPEND="cifs? ( net-fs/cifs-utils )
	ipmi? ( sys-apps/ipmitool )
	zabbix? ( net-analyzer/zabbix[agent] )
	sys-block/nbd
	=app-misc/fc-misc-scripts-9999
	=net-nds/sst-ldap-schemas-9999
	=sys-apps/fc-node-integration-9999
	=x11-themes/fc-artwork-9999
	=www-apps/vm-manager-9999
	=sys-apps/fc-configuration-9999
	~sys-kernel/foss-cloud-bin-3.6.8
	=app-emulation/fc-broker-daemon-9999"

S="${WORKDIR}"

src_compile() {
	version="nightly-$(date +%Y%m%d)"
	echo "${version}" > "foss-cloud_version"

	cat > "os-release" << EOF
NAME=FOSS-Cloud
VERSION="${version}"
ID=foss-cloud
EOF

	echo 'CONFIG_PROTECT_MASK="/etc/os-release /etc/foss-cloud_version"' > 99foss-cloud
}

src_install() {
	insinto /etc
	doins foss-cloud_version os-release

	doenvd 99foss-cloud
}
