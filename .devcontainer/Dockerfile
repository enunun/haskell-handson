# miseの公式Debianイメージ．git，curl，CA証明書とmiseを含み，
# PATHに/mise/shims，MISE_DATA_DIRに/miseが設定済み．
FROM jdxcode/mise:2026.9.12-debian

# build-essential以降は，GHCとHaskellのパッケージのビルドに必要なもの．
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	openssh-client \
	procps \
	jq \
	build-essential \
	pkg-config \
	libffi-dev \
	libgmp-dev \
	libncurses-dev \
	zlib1g-dev \
	xz-utils \
	&& rm -rf /var/lib/apt/lists/*

# ghcupが入れるGHC・cabal・HLSの置き場所．VSCodeのHaskell拡張(HLS)や
# 対話シェルからも使えるように，PATHに加える．
ENV PATH=/root/.ghcup/bin:${PATH} \
    GHCUP_SKIP_UPDATE_CHECK=1

# GHCがソースコード・コマンドライン引数・入出力の日本語を扱えるように，
# ロケールをUTF-8にする．
ENV LANG=C.UTF-8

# ツール(rtk，lefthook，ghcupなど)はmise.tomlのとおりにイメージへ入れ，
# ghcupでGHC・cabal・HLSを入れる．ghcupのキャッシュ，GHCの版と合わないHLS，
# プロファイリング用ライブラリは使わないので消し，イメージを小さくする．
# 版を固定したい場合は，先に`mise lock`でmise.lockを作り，
# COPYの対象に加えたうえで`mise install --locked`にする．
WORKDIR /tmp/mise-bootstrap
COPY mise.toml ./
RUN mise trust \
	&& mise install \
	&& mise run toolchain \
	&& ghcup gc --hls-no-ghc --profiling-libs --cache --tmpdirs

# 起動後は，リポジトリのmise.tomlをグローバル設定として読む．
# これにより，/workspacesの外のディレクトリでも同じツールを使える．
# グローバル設定のルートも/workspacesにして，タスクをリポジトリ直下で実行させる
# (未指定だとホームディレクトリで実行される)．
ENV MISE_GLOBAL_CONFIG_FILE=/workspaces/mise.toml \
    MISE_GLOBAL_CONFIG_ROOT=/workspaces \
    MISE_TRUSTED_CONFIG_PATHS=/workspaces

WORKDIR /workspaces
