# Python開発環境を持つdebianイメージ
# 日本語化も設定済み
FROM        kagalpandh/kacpp-gccdev AS builder
SHELL       [ "/bin/bash", "-c" ]
WORKDIR     /root
ENV         DEBIAN_FORONTEND=noninteractive
# GAWK関連環境変数
ENV         GAWK_VERSION=5.1.0
ENV         GAWK_NAME=gawk-${GAWK_VERSION}
ENV         GAWK_SRC_FILE=${GAWK_NAME}.tar.xz
ENV         GAWK_URL=https://ftp.gnu.org/gnu/gawk/gawk-5.1.0.tar.xz
ENV         GAWK_DEST=/root/${GAWK_NAME}
# porg関連環境変数
ENV         PORG_VERSION=0.10
ENV         PORG_SRC_BASE_URL="https://sourceforge.net/projects/porg/files/"
ENV         PORG_SRC_FILE=porg-${PORG_VERSION}.tar.gz
ENV         PORG_SRC_URL="https://sourceforge.net/projects/porg/files/${PORG_SRC_FILE}/download"
ENV         PORG_DEST=/root/porg-${PORG_VERSION}
# 開発環境インストール
RUN         apt update \
            && /usr/local/sh/system/apt-install.sh install gccdev.txt \
            # porgインストール
            && wget ${PORG_SRC_URL} && tar -zxvf ${PORG_SRC_FILE} && cd porg-${PORG_VERSION} \
                && ./configure --prefix=${PORG_DEST} --disable-grop   && make && make install \
            # gawkインストール
            && wget ${GAWK_URL} && tar -Jxvf ${GAWK_SRC_FILE} && cd ${GAWK_NAME} \
                &&  ./configure --prefix=${GAWK_DEST} \
                && make && make install  \
            # 
            && /usr/local/sh/system/apt-install.sh uninstall gccdev.txt \
                && apt autoremove -y && apt clean && rm -rf /var/lib/apt/lists/* \
                && cd ../ && rm -rf ${GAWK_DEST}*
FROM        kagalpandh/kacpp-ja
SHELL       [ "/bin/bash", "-c" ]
WORKDIR     /root
ENV         PORG_VERSION=0.10
ENV         PORG_DEST=porg-${PORG_VERSION}
ENV         GAWK_VERSION=5.1.0
ENV         GAWK_DEST=gawk-${GAWK_VERSION}
COPY        --from=builder /root/${PORG_DEST} /root
COPY        --from=builder /root/${GAWK_DEST} /root
# COPY        rcprofile /etc/rc.d
RUN         apt update && \
            cp -rf ${PORG_DEST}/* /usr/local && porg -l -p ${GAWK_DEST} "cp -rf ${GAWK_DEST}/* /usr/local" && \
            cd ~/ && apt clean && rm -rf /var/lib/apt/lists/* && rm -rf /root/${PORG_DEST} && \
            rm -rf /root/${GAWK_DEST}
