import { env as baseEnv } from '$env/dynamic/public';
import { z } from 'zod';

const envSchema = z.object({
	PUBLIC_BACKEND_URL: z.string(),
	PUBLIC_REPLICACHE_LICENSE_KEY: z.string()
});

export const env = envSchema.parse(baseEnv);
