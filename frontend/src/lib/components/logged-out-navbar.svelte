<script lang="ts">
	import { Disclosure, DisclosureButton, DisclosurePanel } from '@rgossiaux/svelte-headlessui';
	import { Icon, XMark, Bars3 } from 'svelte-hero-icons';
	import { cn } from '$lib/utils';
	import { page } from '$app/stores';
	import Logo from './logo.svelte';

	export let links: { name: string; href: string }[] = [];

	const currentLink = links.find((link) => link.href === $page.url.pathname);
</script>

<Disclosure as="nav" class="bg-gray-800" let:open>
	<div class="mx-auto max-w-7xl px-2 sm:px-6 lg:px-8">
		<div class="relative flex h-16 items-center justify-between">
			{#if links.length > 0}
				<div class="absolute inset-y-0 left-0 flex items-center sm:hidden">
					<DisclosureButton
						class="relative inline-flex items-center justify-center rounded-md p-2 text-gray-400 hover:bg-gray-700 hover:text-white focus:outline-none focus:ring-2 focus:ring-inset focus:ring-white"
					>
						<span class="absolute -inset-0.5" />
						<span class="sr-only">Open main menu</span>
						{#if open}
							<Icon src={XMark} class="block h-6 w-6" aria-hidden="true" />
						{:else}
							<Icon src={Bars3} class="block h-6 w-6" aria-hidden="true" />
						{/if}
					</DisclosureButton>
				</div>
			{/if}
			<div class="flex flex-1 items-center justify-center sm:items-stretch sm:justify-start">
				<div class={cn('flex flex-shrink-0 items-center', { 'mr-auto': links.length === 0 })}>
					<a href="/">
						<Logo />
					</a>
				</div>
				<div class="hidden sm:ml-6 sm:block">
					<div class="flex space-x-4">
						{#each links as item (item.name)}
							<a
								href={item.href}
								class={cn(
									item === currentLink
										? 'bg-gray-900 text-white'
										: 'text-gray-300 hover:bg-gray-700 hover:text-white',
									'rounded-md px-3 py-2 text-sm font-medium'
								)}
								aria-current={item === currentLink ? 'page' : undefined}
							>
								{item.name}
							</a>
						{/each}
					</div>
				</div>
			</div>
			<div class="flex flex-1 items-center justify-end gap-4">
				<a
					href="login"
					class={cn('text-white rounded-md px-3 py-2 text-sm font-medium hover:bg-gray-700', {
						'bg-gray-900': $page.url.pathname === '/login'
					})}
				>
					Login
				</a>
				<a
					href="/sign-up"
					class={cn('text-white rounded-md px-3 py-2 text-sm font-medium hover:bg-gray-700', {
						'bg-gray-900': $page.url.pathname === '/sign-up'
					})}
				>
					Register
				</a>
			</div>
		</div>
	</div>

	<DisclosurePanel class="sm:hidden">
		<div class="space-y-1 px-2 pb-3 pt-2">
			{#each links as item (item.name)}
				<DisclosureButton
					as="a"
					href={item.href}
					class={cn(
						item === currentLink
							? 'bg-gray-900 text-white'
							: 'text-gray-300 hover:bg-gray-700 hover:text-white',
						'block rounded-md px-3 py-2 text-base font-medium'
					)}
					aria-current={item === currentLink ? 'page' : undefined}
				>
					{item.name}
				</DisclosureButton>
			{/each}
		</div>
	</DisclosurePanel>
</Disclosure>
