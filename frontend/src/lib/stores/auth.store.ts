import { writable } from 'svelte/store';
import { browser } from '$app/environment';
import { goto } from '$app/navigation';

const localStorageKey = 'bleeding_todo:jwt';

const persistedJwt = browser && localStorage.getItem(localStorageKey);

export const getAuthJwt = () => {
	if (!browser) {
		throw new Error('getAuthJwt must only be called inside a browser');
	}

	return localStorage.getItem(localStorageKey);
};

const createAuthStore = () => {
	const { subscribe, set } = writable(persistedJwt || null);

	return {
		subscribe,
		logout: (redirect = '/') => {
			set(null);
			localStorage.removeItem(localStorageKey);
			goto(redirect);
		},
		login: (jwt: string, redirect = '/dashboard') => {
			set(jwt);
			localStorage.setItem(localStorageKey, jwt);
			goto(redirect);
		}
	};
};

export const authStore = createAuthStore();
