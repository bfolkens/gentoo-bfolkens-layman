# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/mosh/mosh-1.2.ebuild,v 1.1 2012/04/26 07:58:50 xmw Exp $

EAPI=4

inherit autotools toolchain-funcs

DESCRIPTION="Mobile shell that supports roaming and intelligent local echo"
HOMEPAGE="http://mosh.mit.edu"
SRC_URI="https://github.com/downloads/keithw/${PN}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+client examples +server +utempter"
REQUIRED_USE="|| ( client server )
	examples? ( client )"

RDEPEND="dev-libs/protobuf
    dev-libs/skalibs
	sys-libs/ncurses:5
	virtual/ssh
	client? ( dev-lang/perl
		dev-perl/IO-Tty )
	utempter? ( sys-libs/libutempter )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_prepare() {
	einfo remove bundled skalibs
	rm -r third || die
	sed -e '/third/d' -i configure.ac
	sed -e '/^SUBDIRS/s: third : :' -i Makefile.am

	eautoreconf
}

src_configure() {
	econf \
		--with-skalibs=/ \
		--with-skalibs-include=/usr/include/skalibs \
		--with-skalibs-libdir=/usr/$(get_libdir)/skalibs \
		$(use_enable client) \
		$(use_enable server) \
		$(use_enable examples) \
		$(use_with utempter)
}

src_install() {
	default

	for myprog in $(find src/examples -type f -perm /0111) ; do
		newbin ${myprog} ${PN}-$(basename ${myprog})
		elog "${myprog} installed as ${PN}-$(basename ${myprog})"
	done
}
