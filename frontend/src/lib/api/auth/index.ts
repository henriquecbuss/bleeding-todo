import { signInSchema } from './sign-in';
import { signUpSchema } from './sign-up';

export const authSchema = {
	'sign-up': signUpSchema,
	'sign-in': signInSchema
};
