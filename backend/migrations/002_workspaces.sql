CREATE TYPE workspace_icon AS ENUM ('academic-cap', 'archive-box', 'banknotes', 'beaker', 'bolt', 'book-open', 'bookmark', 'briefcase', 'building-storefront', 'chart-bar', 'clock', 'command-line', 'cpu-chip', 'cube', 'currency-dollar', 'exclamation-circle', 'fire', 'light-bulb', 'map', 'paint-brush', 'puzzle-piece', 'rocket-launch', 'sparkles', 'swatch');

CREATE TYPE workspace_permission AS ENUM ('ws:delete', 'ws:invite', 'ws:kick', 'ws:edit', 'ws:list:create', 'ws:list:delete', 'ws:list:edit', 'ws:list:item:create', 'ws:list:item:complete', 'ws:list:item:delete', 'ws:list:item:edit');

CREATE TABLE workspaces (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    name text NOT NULL,
    icon workspace_icon NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now()
);
COMMENT ON COLUMN workspaces.icon IS 'An icon from Hero Icons';

CREATE UNIQUE INDEX workspaces_pkey ON workspaces(id uuid_ops);

CREATE TABLE workspace_users (
    workspace_id uuid REFERENCES workspaces(id) ON DELETE CASCADE ON UPDATE CASCADE,
    user_id uuid REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    permissions workspace_permission[] NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT workspace_users_pkey PRIMARY KEY (workspace_id, user_id)
);

CREATE UNIQUE INDEX workspace_users_pkey ON workspace_users(workspace_id uuid_ops,user_id uuid_ops);
