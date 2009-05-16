# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/dahdi/dahdi-2.1.0.4.ebuild,v 1.1 2009/03/10 16:32:11 chainsaw Exp $

inherit linux-mod eutils flag-o-matic

MY_P="${P/dahdi/dahdi-linux}"
MY_S="${WORKDIR}/${MY_P}"

DESCRIPTION="Kernel modules for Digium compatible hardware (formerly known as Zaptel)."
HOMEPAGE="http://www.asterisk.org"
SRC_URI="http://downloads.digium.com/pub/telephony/dahdi-linux/releases/${MY_P}.tar.gz
http://downloads.digium.com/pub/telephony/firmware/releases/dahdi-fw-oct6114-064-1.05.01.tar.gz
http://downloads.digium.com/pub/telephony/firmware/releases/dahdi-fw-oct6114-128-1.05.01.tar.gz
http://downloads.digium.com/pub/telephony/firmware/releases/dahdi-fw-tc400m-MR6.12.tar.gz
http://downloads.digium.com/pub/telephony/firmware/releases/dahdi-fw-vpmadt032-1.07.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND=""

src_unpack() {
	unpack ${A}

	# Fix udev rules to work with both asterisk and callweaver
	sed -i 's/GROUP="asterisk"/GROUP="dialout"/' "${MY_S}"/build_tools/genudevrules

	# Copy the firmware tarballs over, the makefile will try and download them otherwise
	for file in ${A} ; do
		cp "${DISTDIR}"/${file} "${MY_P}"/drivers/dahdi/firmware/
	done
	# But without the .bin's it'll still fall over and die, so copy those too.
	cp *.bin "${MY_P}"/drivers/dahdi/firmware/

	epatch "${FILESDIR}"/${P}-no-depmod.patch

	# http://bugs.digium.com/view.php?id=14285
	epatch "${FILESDIR}"/${P}-netdev-2-6-29.patch

	# https://issues.asterisk.org/view.php?id=13930
	epatch "${FILESDIR}"/${P}-no_dahdi_dummy_rtc-3.patch
}

src_compile() {
	cd "${MY_P}"
	unset ARCH
	emake KSRC="${KERNEL_DIR}" DESTDIR="${D}" modules || die "failed to build module"
}

src_install() {
	cd "${MY_P}"

	# setup directory structure so udev rules get installed
	mkdir -p "${D}"/etc/udev/rules.d

	einfo "Installing kernel module"
	emake KSRC="${KERNEL_DIR}" DESTDIR="${D}" install || die "failed to install module"
	rm -rf "$D"/lib/modules/*/modules.*
}
