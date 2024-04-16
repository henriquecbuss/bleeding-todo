import { z } from 'zod';

const input = z.object({
	emailOrUsername: z.string(),
	rawPassword: z.string().min(6)
});

const output = z.object({
	jwt: z.string()
});

const error = z.object({
	error: z.string()
});

export const signInSchema = {
	route: '/auth/sign-in',
	POST: {
		input,
		output,
		error
	}
};
