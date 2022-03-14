# WSL Container for Developers

開発 PC の WSL にインポートして使うためのコンテナ

## 編集・ビルド用セットアップ

asdf のプラグインをインストールする

```bash
asdf plugin-add direnv \
  ; asdf plugin-add hadolint \
  ; asdf plugin-add nodejs \
  ; asdf plugin-add python
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
