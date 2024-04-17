<script lang="ts">
	import Logo from '$lib/components/logo.svelte';
	import { cn } from '$lib/utils';
	import { ArrowRightStartOnRectangle, CurrencyDollar, Home } from 'svelte-hero-icons';
	import SidebarItem from './sidebar-item.svelte';
	import { authStore } from '$lib/stores/auth.store';

	export let className = '';

	const currentListId = 'abc';

	const lists = [
		{ id: 'abc', title: 'House Tasks', icon: Home, href: '/' },
		{ id: 'bcd', title: 'Finances', icon: CurrencyDollar, href: '/finances' },
		{
			id: 'cde',
			title: 'Very Very Very Very Very Long Name',
			icon: CurrencyDollar,
			href: '/finances'
		}
	];

	const currentWorkspaceId = 'abc';

	const workspaces = [
		{ id: 'abc', title: 'House Tasks', icon: Home, href: '/' },
		{ id: 'bcd', title: 'Finances', icon: CurrencyDollar, href: '/finances' },
		{
			id: 'cde',
			title: 'Very Very Very Very Very Long Name',
			icon: CurrencyDollar,
			href: '/long'
		}
	];
</script>

<div class={cn('flex flex-col bg-gray-800 w-60 h-full text-gray-200 overflow-y-auto', className)}>
	<div class="h-16 px-4 shrink-0 flex items-center">
		<Logo />
	</div>

	<div class="flex flex-col flex-1 px-2 pb-4 pt-6 gap-1">
		{#each lists as list (list.id)}
			<SidebarItem
				as="a"
				href={list.href}
				current={list.id === currentListId}
				title={list.title}
				icon={list.icon}
			/>
		{/each}

		<p class="text-xs text-gray-300 mt-6 mb-2 ml-2">Workspaces</p>

		<svelte:element this={'a'} />

		{#each workspaces as workspace (workspace.id)}
			<SidebarItem
				as="a"
				href={workspace.href}
				current={workspace.id === currentWorkspaceId}
				title={workspace.title}
				icon={workspace.icon}
			/>
		{/each}

		<div class="mt-auto hidden md:flex">
			<SidebarItem
				className="mt-10 w-full"
				as="button"
				title="Sign out"
				icon={ArrowRightStartOnRectangle}
				on:click={() => authStore.logout()}
			/>
		</div>
	</div>
</div>
