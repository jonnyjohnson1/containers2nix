-- +migrate Up

--
-- accounts
--
create table accounts (
  id                    integer             primary key,
  email                 string              not null unique,
  password              string              not null,
  token                 string              not null unique,
  created_at            datetime            not null default(strftime('%Y-%m-%d %H:%M:%f', 'now')),
  updated_at            datetime            not null default(strftime('%Y-%m-%d %H:%M:%f', 'now')),

  constraint chk_email check (email <> ''),
  constraint chk_password check (password <> ''),
  constraint chk_token check(token <> '')
);

--
-- account_requests
--
create table account_requests (
  id                    integer             primary key,
  token                 string              not null unique,
  email                 string              not null unique,
  source_address        string              not null,
  created_at            datetime            not null default(strftime('%Y-%m-%d %H:%M:%f', 'now')),
  updated_at            datetime            not null default(strftime('%Y-%m-%d %H:%M:%f', 'now'))
);

--
-- environments
--
create table environments (
  id                    integer             primary key,
  account_id            integer             constraint fk_accounts_identities references accounts on delete cascade,
  description           string,
  host                  string,
  address               string,
  z_id                  string              not null unique,
  created_at            datetime            not null default(strftime('%Y-%m-%d %H:%M:%f', 'now')),
  updated_at            datetime            not null default(strftime('%Y-%m-%d %H:%M:%f', 'now')),

  constraint chk_z_id check (z_id <> '')
);

--
-- services
--
create table services (
  id                    integer             primary key,
  environment_id        integer             constraint fk_environments_services references environments on delete cascade,
  z_id                  string              not null unique,
  name                  string              not null unique,
  frontend              string,
  backend               string,
  created_at            datetime            not null default(strftime('%Y-%m-%d %H:%M:%f', 'now')),
  updated_at            datetime            not null default(strftime('%Y-%m-%d %H:%M:%f', 'now')),

  constraint chk_z_id check (z_id <> ''),
  constraint chk_name check (name <> '')
);