import { env } from '$lib/env/public';
import { Replicache as ReplicacheClass } from 'replicache';
import { authStore } from './stores/auth.store';
import { createList, deleteList, editList } from './replicache/mutators/lists';
import { derived } from 'svelte/store';
import { page } from '$app/stores';

const createReplicache = ({
	jwt,
	userId,
	workspaceId
}: {
	jwt: string;
	userId: string;
	workspaceId: string;
}) => {
	return new ReplicacheClass({
		name: `${userId}-${workspaceId}`,
		licenseKey: env.PUBLIC_REPLICACHE_LICENSE_KEY,
		pushURL: `${env.PUBLIC_BACKEND_URL}/workspace/${workspaceId}/replicache/push`,
		pullURL: `${env.PUBLIC_BACKEND_URL}/workspace/${workspaceId}/replicache/pull`,
		auth: `Bearer ${jwt}`,
		mutators: {
			createList,
			deleteList,
			editList
		}
	});
};

type Replicache = ReturnType<typeof createReplicache>;

export type ReplicacheStore = typeof replicacheStore;

export const replicacheStore = derived<[typeof authStore, typeof page], Replicache | undefined>(
	[authStore, page],
	([auth, page], set) => {
		const workspaceId = page.params.workspaceId;

		if (!auth || !workspaceId) {
			return undefined;
		}

		const replicache = createReplicache({
			jwt: auth.jwt,
			userId: auth.user.id,
			workspaceId
		});

		set(replicache);

		const evtSource = new EventSource(
			`${env.PUBLIC_BACKEND_URL}/sse/workspace/${workspaceId}/replicache/poke`
		);

		evtSource.onmessage = () => {
			replicache.pull();
		};

		return () => {
			replicache.close();
			evtSource.close();
		};
	}
);

export const mutationStore = derived(replicacheStore, (replicache) => replicache?.mutate);
