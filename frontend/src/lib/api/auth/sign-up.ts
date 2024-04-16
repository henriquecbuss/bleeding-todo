import { z } from 'zod';

const input = z.object({
	email: z.string().email(),
	username: z.string().min(2),
	rawPassword: z.string().min(6)
});

const output = z.object({
	jwt: z.string()
});

const error = z.object({
	error: z.string()
});

export const signUpSchema = {
	route: '/auth/sign-up',
	POST: {
		input,
		output,
		error
	}
};
