import { writable } from 'svelte/store';
import { browser } from '$app/environment';

const localStorageKey = 'bleeding_todo:jwt';

const persistedJwt = browser && localStorage.getItem(localStorageKey);

export const getAuthJwt = () => {
	if (!browser) {
		throw new Error('getAuth must only be called inside a browser');
	}

	return localStorage.getItem(localStorageKey);
};

export const authStore = writable(persistedJwt ? persistedJwt : '');

if (browser) {
	authStore.subscribe((jwt) => (localStorage[localStorageKey] = jwt));
}
