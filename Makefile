DB51DIR=/usr/local/db51
DB51VERSION=db-5.1.29.NC
DB51FILE=$(DB51VERSION).tar.gz
DB51URL=http://download.oracle.com/berkeley-db/db-5.1.29.NC.tar.gz
DB51HASH=08238E59736D1AACDD47CFB8E68684C695516C37F4FBE1B8267DDE58DC3A576C

PACKAGES=                      \
  automake                     \
  autotools-dev                \
  bsdmainutils                 \
  build-essential              \
  libboost-chrono-dev          \
  libboost-filesystem-dev      \
  libboost-program-options-dev \
  libboost-system-dev          \
  libboost-test-dev            \
  libboost-thread-dev          \
  libevent-dev                 \
  libminiupnpc-dev             \
  libprotobuf-dev              \
  libqrencode-dev              \
  libqt5core5a                 \
  libqt5dbus5                  \
  libqt5gui5                   \
  libssl-dev                   \
  libtool                      \
  libzmq3-dev                  \
  pkg-config                   \
  protobuf-compiler            \
  qttools5-dev                 \
  qttools5-dev-tools           \

all:
	apt-get -y install $(PACKAGES)
	if [ ! -d $(DB4DIR) ]; then                                                              \
		if [ ! -f $(DB51FILE) ]; then                                                     \
			wget $(DB51URL);                                                          \
		fi                                                                            && \
		echo $(DB51HASH) $(DB51FILE) | sha256sum -c                                     && \
		rm -Rf $(DB51VERSION)                                                          && \
		tar -xzvf $(DB51FILE)                                                          && \
		cd $(DB51VERSION)/build_unix/                                                  && \
		../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$(DB51DIR) && \
		mkdir -p $(DB51DIR)                                                            && \
		make install;                                                                    \
	fi
	if [ ! -d dogecoin ]; then                                                            \
		git clone https://github.com/dogecoin/dogecoin.git                          && \
		cd dogecoin                                                                && \
		CURRENT=`git tag | grep -P '^v[\d\.]+$$' | sort --version-sort | tail -1` && \
		git checkout tags/$$CURRENT -b local-$$CURRENT                            && \
		./autogen.sh                                                              && \
		./configure --without-gui LDFLAGS="-L$(DB51DIR)/lib/" CPPFLAGS="-I$(DB51DIR)/include/";      \
	fi

install: all
	cd dogecoin;     \
	  make install; \

clean:
	rm -Rf dogecoin
	rm -Rf $(DB51VERSION)
	rm -f $(DB51FILE)
