# WSL Container for Developers

開発 PC の WSL にインポートして使うためのコンテナ

## 必要な環境

### ビルド環境

macOS 、 Linux もしくは Windows の WSL 上でビルドする

- [asdf]
- [Docker]
- [docker-compose]

### WSL 環境

Windows の WSL にインポートする

[WSL2]

## 編集・ビルド用セットアップ

asdf のプラグインをインストールする

```bash
asdf plugin-add direnv \
  ; asdf plugin-add hadolint \
  ; asdf plugin-add nodejs \
  ; asdf plugin-add python \
  ; asdf plugin-add shellcheck
```

asdf で Python と Node.js をインストールする

```bash
asdf install
```

依存パッケージをインストールする

```bash
npm install \
  && pip install --requirement requirements.txt
```

静的解析を実行する

```bash
pre-commit run --all-files
```

静的解析をコミット時に自動実行する

```bash
pre-commit install
```

## コンテナのビルド

### 非プロキシー環境

```bash
docker-compose build
```

### プロキシー環境

proxy ブランチに切り替えてからビルドする

```bash
git brach proxy
```

環境変数が設定されていることを確認する

```bash
printenv http_proxy
```

環境変数が設定されていない場合、設定してからビルドする

```bash
export http_proxy=<プロキシサーバー:ポート番号>
```

```bash
docker-compose build
```

## コンテナのエクスポート

コンテナの起動

```bash
docker-compose up -d
```

コンテナのエクスポート

```bash
docker export dev -o dev.tar.gz
```

コンテナの停止・削除

```bash
docker-compose down
```

## コンテナの動作確認

コンテナ内に AWS 設定や Git 設定を引き継ぎたい場合、以下のように起動する

```bash
docker-compose \
  -f docker-compose.yml \
  -f docker-compose.exec.yml \
  up -d
```

```bash
docker exec -it dev zsh
```

## コンテナのインポート

以降は WSL を起動する Windows 上の PowerShell ターミナルで実行する

```ps
wsl --import dev $HOME/AppData/dev ./dev.tar.gz
```

コンテナ (WSL のディストリビューション) を削除する場合は以下のコマンドを実行する

入れ替える場合は削除後に再度インポートする

```ps
wsl --unregister dev
```

## WSL の設定

初回導入時、以下に示す ./config/.wslconfig を編集し、ホームディレクトリーにコピーする

```text
localhostForwarding=True # localhost で WSL にアクセスできるようにする
memory=2GB # メモリサイズは環境によって変更する
```

```ps
cp ./config/.wslconfig ~/.wslconfig
```

## WSL の起動

```ps
wsl -d dev
```

## WSL への設定情報のコピー

Windows の設定情報を WSL 上にコピーする

### AWS の設定情報

```bash
./scripts/copy_aws_config.sh
```

AWS に接続できることを確認する

```bash
aws sts get-caller-identity
```

### SSH の設定情報

```bash
./scripts/copy_ssh_config.sh
```

パスフレーズを設定している場合、入力を求められる

```bash
Enter passphrase for /home/ubuntu/.ssh/<秘密鍵ファイル>:
```

SSH 接続できることを確認する

```bash
ssh github.com
```

### Git の設定情報

```bash
./scripts/copy_git_config.sh
```

Git の設定情報を確認する

```bash
git config user.name
git config user.email
```

## WSL への VSCode 拡張機能のインストール

```bash
./scripts/install_vscode_extensions.sh
```

[asdf]: https://github.com/asdf-vm/asdf
[docker]: https://www.docker.com/
[docker-compose]: https://docs.docker.jp/compose/toc.html
[wsl2]: https://docs.microsoft.com/ja-jp/windows/wsl/install
