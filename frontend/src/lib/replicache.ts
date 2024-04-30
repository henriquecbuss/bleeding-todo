import { browser } from '$app/environment';
import { env } from '$lib/env/public';
import { Replicache as ReplicacheClass } from 'replicache';
import { getAuthJwt } from './stores/auth.store';
import { createList, deleteList, editList } from './replicache/mutators/lists';

const createReplicache = () => {
	if (!browser) {
		return null;
	}

	const auth = getAuthJwt();
	const licenseKey = env.PUBLIC_REPLICACHE_LICENSE_KEY;
	// TODO: Use real workspaceId
	const workspaceId = 'bb22b656-7ec4-4825-9b42-756e08ddfc6c';

	return new ReplicacheClass({
		name: 'user-id',
		licenseKey,
		pushURL: `${env.PUBLIC_BACKEND_URL}/workspace/${workspaceId}/replicache/push`,
		pullURL: `${env.PUBLIC_BACKEND_URL}/workspace/${workspaceId}/replicache/pull`,
		logLevel: 'debug',
		auth: auth ? `Bearer ${auth}` : undefined,
		mutators: {
			createList,
			deleteList,
			editList
		}
	});
};

export type Replicache = NonNullable<typeof replicache>;

export const replicache = createReplicache();
