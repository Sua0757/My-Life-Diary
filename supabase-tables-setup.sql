-- ============================================================
-- My Life手帳：データ保存テーブルの権限・セキュリティ設定（一度だけ実行）
-- Supabase ダッシュボード → 左メニュー「SQL Editor」→「New query」
-- ここに全文を貼り付けて「Run」を押してください。
--
-- 目的：アポ(apos)・紹介(referrals)・その他(app_data)を、
--       ログイン中の本人だけが「読む・書く・消す」できるようにする。
-- これを実行しないと、アポや紹介がクラウドに保存されず、
-- 他の端末（スマホ／PC）に反映されません。
-- 何度実行しても安全な内容です（既存データは消えません）。
-- ============================================================

-- 1) テーブル（無ければ作成。既にあれば変更しません）
create table if not exists public.app_data (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.apos (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.referrals (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- 2) 行レベルセキュリティ（RLS）を有効化
alter table public.app_data  enable row level security;
alter table public.apos      enable row level security;
alter table public.referrals enable row level security;

-- 3) ログインユーザーにテーブル権限を付与（実際の行はRLSで本人分だけに制限）
grant select, insert, update, delete on table public.app_data  to authenticated;
grant select, insert, update, delete on table public.apos      to authenticated;
grant select, insert, update, delete on table public.referrals to authenticated;

-- 4) 「本人の行だけ」読み書きできるポリシー（読む・作る・更新・消す すべて）
--    ※ INSERT/UPDATE には with check が必須。これが無いと「保存」が失敗します。
drop policy if exists "own app_data" on public.app_data;
create policy "own app_data" on public.app_data
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "own apos" on public.apos;
create policy "own apos" on public.apos
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "own referrals" on public.referrals;
create policy "own referrals" on public.referrals
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ============================================================
-- 実行後の手順：
-- 1) パソコン(Web)で My Life手帳 を開く
-- 2) ⚙設定 →「☁ この端末の内容をクラウドへアップロード」を押す
--    （ブラウザ内にある13件のアポがクラウドへ保存されます）
-- 3) スマホで ⚙設定 →「⬇ クラウドから最新を取り込む」を押す
--    （13件が表示されます）
-- ============================================================
