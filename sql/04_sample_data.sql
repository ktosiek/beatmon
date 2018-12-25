with
  users as (
    insert into beatmon.account (email, is_active, is_admin)
      values ('admin@example.com', true, true)
           , ('user@example.com', true, false)
      on conflict (email) do update set is_active = true
      returning account_id, email
  )
select users.*, internal.set_password(users.account_id, 'asdf') from users;