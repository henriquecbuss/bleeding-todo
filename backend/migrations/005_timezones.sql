ALTER TABLE "public"."users" ALTER COLUMN "created_at" SET DEFAULT (now() at time zone 'utc');
ALTER TABLE "public"."users" ALTER COLUMN "updated_at" SET DEFAULT (now() at time zone 'utc');

ALTER TABLE "public"."user_sessions" ALTER COLUMN "created_at" SET DEFAULT (now() at time zone 'utc');

ALTER TABLE "public"."workspaces" ALTER COLUMN "created_at" SET DEFAULT (now() at time zone 'utc');
ALTER TABLE "public"."workspaces" ALTER COLUMN "updated_at" SET DEFAULT (now() at time zone 'utc');

ALTER TABLE "public"."workspace_users" ALTER COLUMN "created_at" SET DEFAULT (now() at time zone 'utc');
ALTER TABLE "public"."workspace_users" ALTER COLUMN "updated_at" SET DEFAULT (now() at time zone 'utc');

ALTER TABLE "public"."lists" ALTER COLUMN "created_at" SET DEFAULT (now() at time zone 'utc');
ALTER TABLE "public"."lists" ALTER COLUMN "updated_at" SET DEFAULT (now() at time zone 'utc');

ALTER TABLE "public"."list_items" ALTER COLUMN "created_at" SET DEFAULT (now() at time zone 'utc');
ALTER TABLE "public"."list_items" ALTER COLUMN "updated_at" SET DEFAULT (now() at time zone 'utc');
