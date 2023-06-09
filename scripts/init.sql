-- used for integration tests

-- Create schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS api;

DROP TABLE IF EXISTS api.todos;

-- Useful to reset the table after the integration tests
CREATE OR REPLACE FUNCTION api.create_and_populate_todos()
RETURNS VOID AS $$
BEGIN
  -- Create table
  CREATE TABLE IF NOT EXISTS api.todos (
    id serial primary key,
    done boolean not null default false,
    task text not null,
    due timestamptz
  );
  TRUNCATE api.todos RESTART IDENTITY CASCADE;

  -- Insert data only if the table is empty
  INSERT INTO api.todos (task, done)
  SELECT * FROM (VALUES
    ('finish tutorial 0', TRUE),
    ('pat self on back', TRUE),
    ('learn how to auth', TRUE),
    ('write the lua library', FALSE)
  ) AS t(task, done);
END;
$$ LANGUAGE plpgsql;

SELECT api.create_and_populate_todos();


-- Revoke privileges if they were granted before
DO $$ BEGIN
  BEGIN
    REVOKE ALL PRIVILEGES ON SCHEMA api FROM web_anon;
  EXCEPTION
    WHEN undefined_object THEN
      NULL;
  END;
END $$;

-- Drop role if it exists, then re-create it
DROP ROLE IF EXISTS web_anon;
CREATE ROLE web_anon NOLOGIN;

-- Grant privileges
GRANT USAGE ON SCHEMA api TO web_anon;
GRANT SELECT ON api.todos TO web_anon;

-- Drop role if it exists, then re-create it and grant privileges
DROP ROLE IF EXISTS authenticator;
CREATE ROLE authenticator noinherit login password 'mysecretpassword';
GRANT web_anon TO authenticator;

-- Revoke privileges if they were granted before
DO $$ BEGIN
  BEGIN
    REVOKE ALL PRIVILEGES ON SCHEMA api FROM todo_user;
  EXCEPTION
    WHEN undefined_object THEN
      NULL;
  END;
END $$;

-- Drop role if it exists, then re-create it
DROP ROLE IF EXISTS todo_user;
CREATE role todo_user nologin;
GRANT todo_user TO authenticator;

GRANT USAGE ON schema api TO todo_user;
GRANT ALL ON api.todos TO todo_user;

GRANT USAGE, select ON sequence api.todos_id_seq TO todo_user;
