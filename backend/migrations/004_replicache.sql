ALTER TABLE workspaces ADD COLUMN replicache_version bigint NOT NULL DEFAULT 0;

CREATE TABLE replicache_client_groups (
    id text PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    workspace_id uuid NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE UNIQUE INDEX replicache_client_groups_pkey ON replicache_client_groups(id text_ops);

CREATE TABLE replicache_clients (
    id text PRIMARY KEY,
    replicache_client_group_id text NOT NULL REFERENCES replicache_client_groups(id) ON DELETE CASCADE ON UPDATE CASCADE,
    last_mutation_id bigint NOT NULL DEFAULT '0'::bigint,
    last_modified_version bigint NOT NULL DEFAULT '0'::bigint
);

CREATE UNIQUE INDEX replicache_clients_pkey ON replicache_clients(id text_ops);

ALTER TABLE lists ADD COLUMN replicache_last_modified_version bigint NOT NULL DEFAULT 0;

ALTER TABLE lists ADD COLUMN is_deleted boolean NOT NULL DEFAULT false;

ALTER TABLE list_items ADD COLUMN sorting_order bigint NOT NULL DEFAULT 0;

ALTER TABLE list_items ADD COLUMN replicache_last_modified_version bigint NOT NULL DEFAULT 0;

ALTER TABLE list_items ADD COLUMN is_deleted boolean NOT NULL DEFAULT false;
