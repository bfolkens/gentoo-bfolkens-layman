# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/rack/Attic/rack-1.2.1.ebuild,v 1.7 2011/04/24 01:40:03 matsuu Exp $

EAPI="2"
USE_RUBY="ruby18 ree18 ruby19 jruby"

RUBY_FAKEGEM_DOCDIR="doc"

inherit ruby-fakegem eutils versionator

DESCRIPTION="A modular Ruby webserver interface"
HOMEPAGE="http://rubyforge.org/projects/rack"
SRC_URI="mirror://rubyforge/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="$(get_version_component_range 1-2)"
KEYWORDS="~amd64 ~ia64 ~sparc ~x86 ~amd64-linux ~ia64-linux ~x86-linux ~x86-macos ~x64-solaris ~x86-solaris"
IUSE=""

# The gem has automagic dependencies over mongrel, ruby-openid,
# memcache-client, thin, mongrel and camping; not sure if we should
# make them dependencies at all. We do add the fcgi dependency because
# that spec isn't optional.
ruby_add_bdepend "test? ( dev-ruby/bacon dev-ruby/ruby-fcgi )"

# Block against versions in older slots that also try to install a binary.
RDEPEND="${RDEPEND} !<dev-ruby/rack-1.1.0-r1:0"

#USE_RUBY=ruby19 \
#	ruby_add_bdepend "ruby_targets_ruby19 test" '=dev-ruby/test-unit-1*'

all_ruby_prepare() {
	epatch "${FILESDIR}"/${P}-gentoo.patch
}

each_ruby_test() {
	# Since the Rakefile calls specrb directly rather than loading it, we
	# cannot use it to launch the tests or only the currently-selected
	# RUBY interpreter will be tested.
	${RUBY} -S bacon -Ilib:spec -w -a \
		-q -t '^(?!Rack::Handler|Rack::Adapter|Rack::Session::Memcache|rackup)' \
		|| die "test failed for ${RUBY}"
}
