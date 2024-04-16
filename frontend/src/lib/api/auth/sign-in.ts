import { z } from 'zod';
import { user, workspace } from '../objects';

const input = z.object({
	emailOrUsername: z.string(),
	rawPassword: z.string().min(6)
});

const output = z.object({
	jwt: z.string(),
	user,
	workspaces: z.array(workspace)
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
