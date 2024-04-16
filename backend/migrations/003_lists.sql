CREATE TABLE lists (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    name text NOT NULL,
    color text NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    workspace_id uuid REFERENCES workspaces(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE UNIQUE INDEX lists_pkey ON lists(id uuid_ops);

CREATE TABLE list_items (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    list_id uuid NOT NULL REFERENCES lists(id) ON DELETE CASCADE ON UPDATE CASCADE,
    title text NOT NULL,
    description_markdown text,
    due_date timestamp with time zone,
    completed_at timestamp with time zone,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    assignee_id uuid REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE UNIQUE INDEX list_items_pkey ON list_items(id uuid_ops);
