# My Life手帳

SES／フリーランス営業コンサルタント向けの顧客管理Webアプリ（単一HTMLファイル）です。
Cloudflare Pages で公開し、GitHub にコードをプッシュするたびに自動でデプロイされます。

## 📁 構成

```
My-Life-Diary/
├── public/
│   └── index.html          ← アプリ本体（これが公開されます）
├── .github/workflows/
│   └── deploy.yml          ← 自動デプロイの設定（GitHub Actions）
├── wrangler.jsonc          ← Cloudflare の設定ファイル
└── README.md               ← このファイル
```

アプリを修正したいときは `public/index.html` を編集してプッシュするだけで、自動的に本番へ反映されます。

## 🌐 公開URL

デプロイが成功すると、次のURLで公開されます（メールアドレスなどの個人情報は含まれません）：

**https://my-life-diary.pages.dev**

---

## ⚙️ 初回だけ必要な設定（あなたの作業）

自動デプロイを動かすには、GitHub に **Cloudflare の鍵（シークレット）を2つ**登録する必要があります。
一度登録すれば、以降はずっと自動で動きます。

### 手順1：Cloudflare の「アカウントID」を調べる

1. https://dash.cloudflare.com にログイン
2. 左メニューの **「Workers & Pages」** をクリック
3. 画面の右側に **「アカウント ID（Account ID）」** が表示されているので、その値をコピーしておく
   （32文字くらいの英数字の文字列です）

### 手順2：Cloudflare の「APIトークン」を作る

1. https://dash.cloudflare.com/profile/api-tokens を開く
2. **「Create Token（トークンを作成）」** をクリック
3. テンプレート一覧から **「Edit Cloudflare Workers」** の横の **「Use template（テンプレートを使用）」** をクリック
   - ※このテンプレートには Pages のデプロイ権限も含まれています
4. そのまま下までスクロールし、**「Continue to summary」→「Create Token」** をクリック
5. 表示された **トークンの文字列をコピー**（この画面を閉じると二度と表示されないので注意！）

### 手順3：GitHub にシークレットとして登録する

1. https://github.com/Sua0757/My-Life-Diary/settings/secrets/actions を開く
2. **「New repository secret」** をクリックして、以下の**1つ目**を登録：
   - **Name**：`CLOUDFLARE_API_TOKEN`
   - **Secret**：手順2でコピーしたトークンを貼り付け
   - 「Add secret」を押す
3. もう一度 **「New repository secret」** をクリックして、**2つ目**を登録：
   - **Name**：`CLOUDFLARE_ACCOUNT_ID`
   - **Secret**：手順1でコピーしたアカウントIDを貼り付け
   - 「Add secret」を押す

### 手順4：デプロイを実行する

シークレットを登録したら、次のどちらかで自動デプロイが走ります：

- **方法A（自動）**：この後コードが更新されると自動でデプロイされます
- **方法B（今すぐ手動で動かす）**：
  1. https://github.com/Sua0757/My-Life-Diary/actions を開く
  2. 左メニューの **「Deploy to Cloudflare Pages」** をクリック
  3. 右側の **「Run workflow」** ボタン → もう一度 **「Run workflow」** をクリック
  4. 1〜2分待つと緑のチェックマークが付き、デプロイ完了です

完了後、**https://my-life-diary.pages.dev** にアクセスするとアプリが表示されます。

---

## 🔧 補足

- **もし `my-life-diary` という名前が既に使われていてエラーになった場合**：
  `.github/workflows/deploy.yml` と `wrangler.jsonc` の中の `my-life-diary` を別の名前
  （例：`mylife-techo` など）に書き換えてプッシュしてください。URLもその名前に変わります。
- **以前作った古いプロジェクト**（`lucky-pond-5984`、`white-recipe-eb80` など）は、
  混乱を避けるため Cloudflare ダッシュボードから削除して構いません。

## 🗄️ バックエンド（Supabase）について

- Project URL：`https://zgeakzkwqwcmiuvgjmwy.supabase.co`
- 認証：メール＋パスワード（新規登録は無効。オーナーが個別に招待）
- ⚠️ 無料プランは **7日間アクセスがないと自動で一時停止**します。定期的にアクセスする仕組みは別途検討予定です。
