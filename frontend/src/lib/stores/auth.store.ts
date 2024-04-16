import { writable } from 'svelte/store';
import { browser } from '$app/environment';
import { goto } from '$app/navigation';
import { user, workspace, type User, type Workspace } from '$lib/api/objects';
import { z } from 'zod';

const localStorageJwtKey = 'bleeding_todo:jwt';
const localStorageUserKey = 'bleeding_todo:user';
const localStorageWorkspacesKey = 'bleeding_todo:workspaces';

const getItem = <T>(key: string, decoder: z.ZodType<T>) => {
	if (!browser) {
		return null;
	}

	const item = localStorage.getItem(key);

	if (!item) {
		return null;
	}

	return decoder.parse(JSON.parse(item));
};

export const getAuthJwt = () => {
	if (!browser) {
		throw new Error('getAuthJwt must only be called inside a browser');
	}

	return localStorage.getItem(localStorageJwtKey);
};

const createAuthStore = () => {
	const initialJwt = browser ? getAuthJwt() : null;
	const initialUser = getItem(localStorageUserKey, user);
	const initialWorkspaces = getItem(localStorageWorkspacesKey, z.array(workspace));

	const { subscribe, set } = writable<null | { jwt: string; user: User; workspaces: Workspace[] }>(
		initialJwt && initialUser && initialWorkspaces
			? {
					jwt: initialJwt,
					user: initialUser,
					workspaces: initialWorkspaces
				}
			: null
	);

	return {
		subscribe,
		logout: (redirect = '/') => {
			set(null);

			localStorage.removeItem(localStorageJwtKey);
			localStorage.removeItem(localStorageUserKey);
			localStorage.removeItem(localStorageWorkspacesKey);

			goto(redirect);
		},
		login: (
			{ jwt, user, workspaces }: { jwt: string; user: User; workspaces: Workspace[] },
			redirect = '/dashboard'
		) => {
			set({ jwt, user, workspaces });

			localStorage.setItem(localStorageJwtKey, jwt);
			localStorage.setItem(localStorageUserKey, JSON.stringify(user));
			localStorage.setItem(localStorageWorkspacesKey, JSON.stringify(workspaces));

			goto(redirect);
		}
	};
};

export const authStore = createAuthStore();
