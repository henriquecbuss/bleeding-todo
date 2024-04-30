import { browser } from '$app/environment';
import { env } from '$lib/env/public';
import { Replicache as ReplicacheClass } from 'replicache';
import { getAuthJwt } from './stores/auth.store';
import { createList, deleteList, editList } from './replicache/mutators/lists';

const createReplicache = () => {
	if (!browser) {
		return null;
	}

	const licenseKey = env.PUBLIC_REPLICACHE_LICENSE_KEY;
	// TODO: Use real workspaceId
	const workspaceId = 'bb22b656-7ec4-4825-9b42-756e08ddfc6c';

	const getAuth = () => {
		const auth = getAuthJwt();

		return auth ? `Bearer ${auth}` : undefined;
	};

	const replicache = new ReplicacheClass({
		name: 'user-id',
		licenseKey,
		pushURL: `${env.PUBLIC_BACKEND_URL}/workspace/${workspaceId}/replicache/push`,
		pullURL: `${env.PUBLIC_BACKEND_URL}/workspace/${workspaceId}/replicache/pull`,
		logLevel: 'debug',
		auth: getAuth(),
		mutators: {
			createList,
			deleteList,
			editList
		}
	});

	replicache.getAuth = getAuth;

	const evtSource = new EventSource(
		`${env.PUBLIC_BACKEND_URL}/sse/workspace/${workspaceId}/replicache/poke`
	);

	evtSource.onmessage = () => {
		replicache.pull();
	};

	return replicache;
};

export type Replicache = NonNullable<typeof replicache>;

export const replicache = createReplicache();
