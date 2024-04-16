<script lang="ts">
	import {
		Disclosure,
		DisclosureButton,
		DisclosurePanel,
		Menu,
		MenuButton,
		MenuItem,
		MenuItems,
		Transition
	} from '@rgossiaux/svelte-headlessui';
	import { Icon, XMark, Bars3, Bell, CheckBadge, User } from 'svelte-hero-icons';
	import { cn } from '$lib/utils';
	import { authStore } from '$lib/stores/auth.store';

	export let links: { name: string; href: string }[] = [];

	const currentLink = links.find((link) => link.href === window.location.pathname);

	const signedIn = !!$authStore;
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
						<Icon src={CheckBadge} class="h-8 w-8 text-white" alt="Bleeding TODO" />
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
			{#if !signedIn}
				<div class="flex flex-1 items-center justify-end gap-4">
					<a
						href="/login"
						class="text-white rounded-md px-3 py-2 text-sm font-medium hover:bg-gray-600"
					>
						Login
					</a>
					<a
						href="/sign-up"
						class="bg-gray-900 text-white rounded-md px-3 py-2 text-sm font-medium hover:bg-gray-700"
					>
						Register
					</a>
				</div>
			{:else}
				<div
					class="absolute inset-y-0 right-0 flex items-center pr-2 sm:static sm:inset-auto sm:ml-6 sm:pr-0"
				>
					<button
						type="button"
						class="relative rounded-full bg-gray-800 p-1 text-gray-400 hover:text-white focus:outline-none focus:ring-2 focus:ring-white focus:ring-offset-2 focus:ring-offset-gray-800"
					>
						<span class="absolute -inset-1.5" />
						<span class="sr-only">View notifications</span>
						<Icon src={Bell} class="h-6 w-6 text-gray-300" aria-hidden="true" />
					</button>

					<Menu as="div" class="relative ml-3">
						<div>
							<MenuButton
								class="relative flex rounded-full bg-gray-800 text-sm focus:outline-none focus:ring-2 focus:ring-white focus:ring-offset-2 focus:ring-offset-gray-800"
							>
								<span class="absolute -inset-1.5" />
								<span class="sr-only">Open user menu</span>
								<div class="h-8 w-8 rounded-full border border-gray-300 p-1.5">
									<Icon src={User} class="text-gray-300" />
								</div>
							</MenuButton>
						</div>
						<Transition
							enter="transition ease-out duration-100"
							enterFrom="transform opacity-0 scale-95"
							enterTo="transform opacity-100 scale-100"
							leave="transition ease-in duration-75"
							leaveFrom="transform opacity-100 scale-100"
							leaveTo="transform opacity-0 scale-95"
						>
							<MenuItems
								class="absolute right-0 z-10 mt-2 w-48 origin-top-right rounded-md bg-white py-1 shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none"
							>
								<MenuItem let:active>
									<a
										href="/profile"
										class={cn(active ? 'bg-gray-100' : '', 'block px-4 py-2 text-sm text-gray-700')}
									>
										Your Profile</a
									>
								</MenuItem>
								<MenuItem let:active>
									<a
										href="/settings"
										class={cn(active ? 'bg-gray-100' : '', 'block px-4 py-2 text-sm text-gray-700')}
									>
										Settings
									</a>
								</MenuItem>
								<MenuItem let:active>
									<button
										on:click={() => authStore.logout()}
										class={cn('block w-full text-left px-4 py-2 text-sm text-gray-700', {
											'bg-gray-100': active
										})}
									>
										Sign out
									</button>
								</MenuItem>
							</MenuItems>
						</Transition>
					</Menu>
				</div>
			{/if}
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
