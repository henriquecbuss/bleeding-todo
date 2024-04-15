CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    email text NOT NULL UNIQUE,
    encrypted_password text NOT NULL,
    username text NOT NULL UNIQUE
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
);

CREATE UNIQUE INDEX users_pkey ON users(id uuid_ops);
CREATE UNIQUE INDEX users_email_key ON users(email text_ops);
CREATE UNIQUE INDEX users_username_key ON users(username text_ops);


CREATE TABLE user_sessions (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    expires_at timestamp with time zone NOT NULL
);

CREATE UNIQUE INDEX user_sessions_pkey ON user_sessions(id uuid_ops);
