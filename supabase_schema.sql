-- Payroll SPBU 3417603 - database online untuk GitHub Pages
-- Jalankan seluruh script ini di Supabase SQL Editor.

create table if not exists public.app_state (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default jsonb_build_object(
    'employees', jsonb_build_array(),
    'payrolls', jsonb_build_array(),
    'settings', jsonb_build_object('workDays', 26, 'izinAmount', 0, 'sakitAmount', 0, 'tkAmount', 0)
  ),
  updated_at timestamptz not null default now()
);

alter table public.app_state enable row level security;

-- Hapus policy lama jika script dijalankan ulang.
drop policy if exists "Users can read own payroll state" on public.app_state;
drop policy if exists "Users can insert own payroll state" on public.app_state;
drop policy if exists "Users can update own payroll state" on public.app_state;

create policy "Users can read own payroll state"
on public.app_state for select
to authenticated
using (auth.uid() = user_id);

create policy "Users can insert own payroll state"
on public.app_state for insert
to authenticated
with check (auth.uid() = user_id);

create policy "Users can update own payroll state"
on public.app_state for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create index if not exists app_state_updated_at_idx on public.app_state(updated_at);

-- Opsional: aktifkan konfirmasi email di Dashboard Supabase > Authentication > Providers.
-- Untuk pemakaian internal SPBU, Anda dapat mematikan email confirmation agar akun langsung bisa masuk.
