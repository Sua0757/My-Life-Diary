-- ============================================================
-- My Life手帳：閲覧専用の共有リンク 初期設定（一度だけ実行）
-- Supabase ダッシュボード → 左メニュー「SQL Editor」→ 「New query」
-- ここに全文を貼り付けて「Run」を押してください。
-- ============================================================

-- 1) 共有トークンを保存するテーブル
create table if not exists public.shares (
  token text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.shares enable row level security;

-- ログインユーザーにテーブル権限を付与（RLSで行は本人分だけに制限されます）
grant select, insert, update, delete on table public.shares to authenticated;

-- 本人だけが、自分の共有リンクを作成・確認・削除できる
drop policy if exists "own shares" on public.shares;
create policy "own shares" on public.shares
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- 2) トークンから「閲覧専用データ」を返す関数（ログイン不要で呼べる）
--    security definer なので、トークンが正しいときだけ本人のデータを読み出して返します。
create or replace function public.get_shared_data(p_token text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid;
  v_app  jsonb;
  v_apos jsonb;
  v_refs jsonb;
begin
  select user_id into v_user from public.shares where token = p_token;
  if v_user is null then
    return null;
  end if;

  select data into v_app from public.app_data where user_id = v_user;

  select coalesce(jsonb_agg(jsonb_build_object('id', id, 'data', data)), '[]'::jsonb)
    into v_apos from public.apos where user_id = v_user;

  select coalesce(jsonb_agg(jsonb_build_object('id', id, 'data', data)), '[]'::jsonb)
    into v_refs from public.referrals where user_id = v_user;

  return jsonb_build_object(
    'app',       coalesce(v_app, '{}'::jsonb),
    'apos',      v_apos,
    'referrals', v_refs
  );
end;
$$;

-- 未ログイン（anon）でも呼べるように権限を付与
grant execute on function public.get_shared_data(text) to anon, authenticated;

-- ============================================================
-- 実行後、アプリの「⚙ 設定 → 閲覧専用リンクで共有 → 🔗 閲覧専用リンクを発行」
-- でリンクが作れるようになります。
-- ============================================================
